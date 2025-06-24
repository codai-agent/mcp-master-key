import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/path_constants.dart';
import 'platform_info.dart';

/// 资源提取器 - ZIP解压版本，高效提取运行时文件
class AssetExtractor {
  static AssetExtractor? _instance;
  late final PlatformInfo _platformInfo;

  AssetExtractor._internal() {
    _platformInfo = PlatformDetector.current;
  }

  /// 获取单例实例
  static AssetExtractor get instance {
    _instance ??= AssetExtractor._internal();
    return _instance!;
  }

  /// 提取所有运行时资源
  Future<void> extractAllRuntimes(String targetBasePath) async {
    print('🚀 Starting runtime extraction to: $targetBasePath');
    
    try {
      // 检查平台支持
      if (_platformInfo.os != 'macos' || _platformInfo.arch != 'arm64') {
        throw Exception('Currently only macOS ARM64 is supported');
      }

      // 确保目标目录存在
      final targetDir = Directory(targetBasePath);
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
        print('📁 Created base directory: $targetBasePath');
      }

      // 提取Python运行时ZIP
      await _extractZipRuntime(
        assetPath: 'assets/runtimes/python.zip',
        targetPath: targetBasePath,
        runtimeName: 'Python',
      );

      // 提取Node.js运行时ZIP
      await _extractZipRuntime(
        assetPath: 'assets/runtimes/nodejs.zip', 
        targetPath: targetBasePath,
        runtimeName: 'Node.js',
      );
      
      // 修复Node.js运行时的NPX路径问题
      await _fixNodejsRuntimePaths(targetBasePath);
      
      print('✅ Runtime extraction completed successfully');
    } catch (e) {
      print('❌ Runtime extraction failed: $e');
      rethrow;
    }
  }

  /// 提取单个ZIP运行时文件
  Future<void> _extractZipRuntime({
    required String assetPath,
    required String targetPath,
    required String runtimeName,
  }) async {
    print('📦 Extracting $runtimeName runtime from $assetPath...');
    
    try {
      // 从assets中读取ZIP文件
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();
      print('📄 Loaded ZIP file: ${bytes.length} bytes');

      // 解压ZIP文件
      final archive = ZipDecoder().decodeBytes(bytes);
      print('📂 ZIP contains ${archive.length} files');

      int extractedCount = 0;
      int skippedCount = 0;

      // 提取每个文件
      for (final file in archive) {
        if (file.isFile) {
          // 构建目标文件路径
          final targetFilePath = '$targetPath/${file.name}';
          final targetFile = File(targetFilePath);

          // 确保目标目录存在
          final targetFileDir = targetFile.parent;
          if (!await targetFileDir.exists()) {
            await targetFileDir.create(recursive: true);
          }

          // 写入文件内容
          await targetFile.writeAsBytes(file.content as List<int>);
          
          // 设置可执行权限（Unix-like系统）
          if (!Platform.isWindows) {
            await _setExecutablePermissionIfNeeded(targetFilePath);
          }

          extractedCount++;
          
          // 每100个文件输出一次进度
          if (extractedCount % 100 == 0) {
            print('📄 Extracted $extractedCount files...');
          }
        } else {
          skippedCount++;
        }
      }

      print('✅ $runtimeName extraction completed:');
      print('   📄 Files extracted: $extractedCount');
      print('   📁 Directories skipped: $skippedCount');
      
    } catch (e) {
      print('❌ Failed to extract $runtimeName runtime: $e');
      rethrow;
    }
  }

  /// 根据文件路径设置可执行权限
  Future<void> _setExecutablePermissionIfNeeded(String filePath) async {
    try {
      // 检查是否为可执行文件（根据路径判断）
      final isExecutable = _shouldBeExecutable(filePath);
      
      if (isExecutable) {
        final result = await Process.run('chmod', ['+x', filePath]);
        if (result.exitCode != 0) {
          print('⚠️ Warning: Failed to set executable permission for $filePath: ${result.stderr}');
        }
      }
    } catch (e) {
      print('⚠️ Warning: Failed to set executable permission for $filePath: $e');
    }
  }

  /// 判断文件是否应该设置为可执行
  bool _shouldBeExecutable(String filePath) {
    final fileName = filePath.split('/').last;
    
    // Python可执行文件
    if (filePath.contains('/python/') && filePath.contains('/bin/')) {
      return _isPythonExecutable(fileName);
    }
    
    // UV可执行文件
    if (filePath.contains('/uv-')) {
      return fileName == 'uv' || fileName == 'uvx';
    }
    
    // Node.js可执行文件
    if (filePath.contains('/nodejs/') && filePath.contains('/bin/')) {
      return _isNodeExecutable(fileName);
    }
    
    return false;
  }

  /// 判断是否为Python可执行文件
  bool _isPythonExecutable(String fileName) {
    const pythonExecutables = {
      'python', 'python3', 'python3.12',
      'pip', 'pip3', 'pip3.12',
      '2to3', '2to3-3.12',
      'idle3', 'idle3.12',
      'pydoc3', 'pydoc3.12',
      'python3-config', 'python3.12-config'
    };
    return pythonExecutables.contains(fileName);
  }

  /// 判断是否为Node.js可执行文件
  bool _isNodeExecutable(String fileName) {
    const nodeExecutables = {
      'node', 'npm', 'npx', 'corepack'
    };
    return nodeExecutables.contains(fileName);
  }

  /// 检查文件是否已存在且有效
  Future<bool> isFileExtracted(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return false;
    }

    // 检查文件大小是否合理（大于0字节）
    final stat = await file.stat();
    return stat.size > 0;
  }

  /// 修复Node.js运行时的路径问题
  /// 主要解决NPX脚本中路径引用不正确的问题
  Future<void> _fixNodejsRuntimePaths(String targetBasePath) async {
    print('🔧 Fixing Node.js runtime paths...');
    
    try {
      // 动态构建Node.js路径（基于平台信息）
      final platform = _platformInfo;
      final nodeVersion = AppConstants.nodeVersion;
      final nodeBasePath = '$targetBasePath/nodejs/${platform.os}/${platform.arch}/node-v$nodeVersion';
      final nodeLibPath = '$nodeBasePath/lib';
      final nodeBinPath = '$nodeBasePath/bin';
      
      final nodeLibDir = Directory(nodeLibPath);
      final nodeBinDir = Directory(nodeBinPath);
      
      if (!await nodeLibDir.exists()) {
        print('⚠️ Node.js lib directory not found: $nodeLibPath');
        return;
      }
      
      if (!await nodeBinDir.exists()) {
        print('⚠️ Node.js bin directory not found: $nodeBinPath');
        return;
      }
      
      // 1. 修复cli.js路径问题
      await _createSymlink(
        sourceRelativePath: 'node_modules/npm/lib/cli.js',
        targetPath: '$nodeLibPath/cli.js',
        basePath: nodeLibPath,
        description: 'NPM cli.js',
      );
      
      // 2. 修复npm-cli.js路径问题（NPX需要）
      await _createSymlink(
        sourceRelativePath: '../lib/node_modules/npm/bin/npm-cli.js',
        targetPath: '$nodeBinPath/npm-cli.js',
        basePath: nodeBinPath,
        description: 'NPM cli binary',
      );
      
    } catch (e) {
      print('❌ Failed to fix Node.js runtime paths: $e');
      // 不抛出异常，让解压过程继续
    }
  }
  
  /// 创建软连接的通用方法
  Future<void> _createSymlink({
    required String sourceRelativePath,
    required String targetPath,
    required String basePath,
    required String description,
  }) async {
    try {
      // 检查源文件是否存在
      final sourceAbsolutePath = '$basePath/$sourceRelativePath';
      final sourceFile = File(sourceAbsolutePath);
      
      if (!await sourceFile.exists()) {
        print('⚠️ $description source not found at: $sourceAbsolutePath');
        return;
      }
      
      // 如果目标文件已存在，先删除
      final targetFile = File(targetPath);
      if (await targetFile.exists()) {
        await targetFile.delete();
        print('🗑️ Removed existing $description link');
      }
      
      // 创建软连接（使用相对路径）
      final result = await Process.run('ln', ['-s', sourceRelativePath, targetPath]);
      
      if (result.exitCode == 0) {
        print('✅ Created $description symlink: $targetPath -> $sourceRelativePath');
        
        // 验证软连接是否正确创建
        final verifyResult = await Process.run('readlink', [targetPath]);
        if (verifyResult.exitCode == 0) {
          final linkTarget = verifyResult.stdout.toString().trim();
          print('🔗 Verified $description symlink target: $linkTarget');
        }
      } else {
        print('❌ Failed to create $description symlink: ${result.stderr}');
      }
      
    } catch (e) {
      print('❌ Failed to create $description symlink: $e');
    }
  }

  /// 检查运行时是否已提取
  Future<bool> isRuntimeExtracted(String targetBasePath) async {
    print('🔍 Checking runtime extraction status...');
    
    // 动态构建关键可执行文件路径（基于平台信息和版本常量）
    final platform = _platformInfo;
    final pythonExe = '$targetBasePath/python/${platform.os}/${platform.arch}/python-${AppConstants.pythonVersion}/bin/python3';
    final uvExe = '$targetBasePath/python/${platform.os}/${platform.arch}/uv-${AppConstants.uvVersion}/uv';
    final nodeExe = '$targetBasePath/nodejs/${platform.os}/${platform.arch}/node-v${AppConstants.nodeVersion}/bin/node';

    final pythonExists = await isFileExtracted(pythonExe);
    final uvExists = await isFileExtracted(uvExe);
    final nodeExists = await isFileExtracted(nodeExe);

    print('📊 Runtime extraction check results:');
    print('  🐍 Python ($pythonExe): ${pythonExists ? '✅' : '❌'}');
    print('  ⚡ UV ($uvExe): ${uvExists ? '✅' : '❌'}');
    print('  📦 Node.js ($nodeExe): ${nodeExists ? '✅' : '❌'}');

    return pythonExists && uvExists && nodeExists;
  }
} 