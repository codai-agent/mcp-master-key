import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/path_constants.dart';
import 'platform_info.dart';

/// 运行时管理器
class RuntimeManager {
  static RuntimeManager? _instance;
  late final PlatformInfo _platformInfo;
  String? _runtimeBasePath;

  RuntimeManager._internal() {
    _platformInfo = PlatformDetector.current;
  }

  /// 获取单例实例
  static RuntimeManager get instance {
    _instance ??= RuntimeManager._internal();
    return _instance!;
  }

  /// 获取当前平台信息
  PlatformInfo get platformInfo => _platformInfo;

  /// 获取运行时基础路径（使用用户主目录避免路径空格问题）
  Future<String> get runtimeBasePath async {
    if (_runtimeBasePath != null) return _runtimeBasePath!;
    
    // 使用用户主目录下的 .mcphub/runtimes，避免 Application Support 中的空格问题
    _runtimeBasePath = PathConstants.getUserRuntimesPath();
    
    // 确保目录存在
    final directory = Directory(_runtimeBasePath!);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      print('✅ Created user runtimes directory: $_runtimeBasePath');
    }
    
    return _runtimeBasePath!;
  }

  /// 获取Python可执行文件路径
  Future<String> getPythonExecutable() async {
    print('🔧 Getting Python executable path...');
    
    final basePath = await runtimeBasePath;
    final platform = _platformInfo;
    
    print('   📍 Runtime base path: $basePath');
    print('   🖥️ Platform: ${platform.os}-${platform.arch}');
    
    String pythonPath;
    switch (platform.os) {
      case 'windows':
        pythonPath = '$basePath/${PathConstants.pythonDirName}/${platform.os}/${platform.arch}/${PathConstants.pythonDirPrefix}${AppConstants.pythonVersion}/${PathConstants.pythonExeName}${PathConstants.getExecutableExtension()}';
        break;
      case 'macos':
      case 'linux':
        pythonPath = '$basePath/${PathConstants.pythonDirName}/${platform.os}/${platform.arch}/${PathConstants.pythonDirPrefix}${AppConstants.pythonVersion}/${PathConstants.pythonBinDir}/${PathConstants.python3ExeName}';
        break;
      default:
        throw UnsupportedError('Unsupported platform: ${platform.os}');
    }
    
    print('   🐍 Python path: $pythonPath');
    
    // 验证文件是否存在
    if (await File(pythonPath).exists()) {
      print('   ✅ Python executable found');
    } else {
      print('   ❌ Python executable not found at expected path');
    }
    
    return pythonPath;
  }

  /// 获取Python可执行文件路径（python命令）
  Future<String> getPythonExecutableAlt() async {
    final basePath = await runtimeBasePath;
    final platform = _platformInfo;
    
    switch (platform.os) {
      case 'windows':
        return '$basePath/${PathConstants.pythonDirName}/${platform.os}/${platform.arch}/${PathConstants.pythonDirPrefix}${AppConstants.pythonVersion}/${PathConstants.pythonExeName}${PathConstants.getExecutableExtension()}';
      case 'macos':
      case 'linux':
        return '$basePath/${PathConstants.pythonDirName}/${platform.os}/${platform.arch}/${PathConstants.pythonDirPrefix}${AppConstants.pythonVersion}/${PathConstants.pythonBinDir}/${PathConstants.pythonExeName}';
      default:
        throw UnsupportedError('Unsupported platform: ${platform.os}');
    }
  }

  /// 获取Pip可执行文件路径
  Future<String> getPipExecutable() async {
    final basePath = await runtimeBasePath;
    final platform = _platformInfo;
    
    switch (platform.os) {
      case 'windows':
        return '$basePath/${PathConstants.pythonDirName}/${platform.os}/${platform.arch}/${PathConstants.pythonDirPrefix}${AppConstants.pythonVersion}/${PathConstants.pipExeName}${PathConstants.getExecutableExtension()}';
      case 'macos':
      case 'linux':
        return '$basePath/${PathConstants.pythonDirName}/${platform.os}/${platform.arch}/${PathConstants.pythonDirPrefix}${AppConstants.pythonVersion}/${PathConstants.pythonBinDir}/${PathConstants.pip3ExeName}';
      default:
        throw UnsupportedError('Unsupported platform: ${platform.os}');
    }
  }

  /// 获取UV可执行文件路径
  Future<String> getUvExecutable() async {
    final basePath = await runtimeBasePath;
    final platform = _platformInfo;
    final extension = PathConstants.getExecutableExtension();
    
    return '$basePath/${PathConstants.pythonDirName}/${platform.os}/${platform.arch}/${PathConstants.uvDirPrefix}${AppConstants.uvVersion}/${PathConstants.uvExeName}$extension';
  }

  /// 获取UVX可执行文件路径
  Future<String> getUvxExecutable() async {
    print('🔧 Getting UVX executable path...');
    
    final basePath = await runtimeBasePath;
    final platform = _platformInfo;
    final extension = PathConstants.getExecutableExtension();
    
    print('   📍 Runtime base path: $basePath');
    print('   🖥️ Platform: ${platform.os}-${platform.arch}');
    print('   📋 Extension: $extension');
    
    final uvxPath = '$basePath/${PathConstants.pythonDirName}/${platform.os}/${platform.arch}/${PathConstants.uvDirPrefix}${AppConstants.uvVersion}/${PathConstants.uvxExeName}$extension';
    
    print('   ⚡ UVX path: $uvxPath');
    
    // 验证文件是否存在
    if (await File(uvxPath).exists()) {
      print('   ✅ UVX executable found');
    } else {
      print('   ❌ UVX executable not found at expected path');
    }
    
    return uvxPath;
  }

  /// 获取Node.js可执行文件路径
  Future<String> getNodeExecutable() async {
    print('🔧 Getting Node.js executable path...');
    
    final basePath = await runtimeBasePath;
    final platform = _platformInfo;
    
    print('   📍 Runtime base path: $basePath');
    print('   🖥️ Platform: ${platform.os}-${platform.arch}');
    
    String nodePath;
    switch (platform.os) {
      case 'windows':
        nodePath = '$basePath/${PathConstants.nodejsDirName}/${platform.os}/${platform.arch}/${PathConstants.nodeDirPrefix}${AppConstants.nodeVersion}/${PathConstants.nodeExeName}${PathConstants.getExecutableExtension()}';
        break;
      case 'macos':
      case 'linux':
        nodePath = '$basePath/${PathConstants.nodejsDirName}/${platform.os}/${platform.arch}/${PathConstants.nodeDirPrefix}${AppConstants.nodeVersion}/${PathConstants.nodeBinDir}/${PathConstants.nodeExeName}';
        break;
      default:
        throw UnsupportedError('Unsupported platform: ${platform.os}');
    }
    
    print('   🟢 Node.js path: $nodePath');
    
    // 验证文件是否存在
    if (await File(nodePath).exists()) {
      print('   ✅ Node.js executable found');
    } else {
      print('   ❌ Node.js executable not found at expected path');
    }
    
    return nodePath;
  }

  /// 获取NPM可执行文件路径
  Future<String> getNpmExecutable() async {
    final basePath = await runtimeBasePath;
    final platform = _platformInfo;
    
    switch (platform.os) {
      case 'windows':
        return '$basePath/${PathConstants.nodejsDirName}/${platform.os}/${platform.arch}/${PathConstants.nodeDirPrefix}${AppConstants.nodeVersion}/${PathConstants.npmExeName}${PathConstants.getScriptExtension()}';
      case 'macos':
      case 'linux':
        return '$basePath/${PathConstants.nodejsDirName}/${platform.os}/${platform.arch}/${PathConstants.nodeDirPrefix}${AppConstants.nodeVersion}/${PathConstants.nodeBinDir}/${PathConstants.npmExeName}';
      default:
        throw UnsupportedError('Unsupported platform: ${platform.os}');
    }
  }

  /// 获取NPX可执行文件路径
  Future<String> getNpxExecutable() async {
    print('🔧 Getting NPX executable path...');
    
    final basePath = await runtimeBasePath;
    final platform = _platformInfo;
    
    print('   📍 Runtime base path: $basePath');
    print('   🖥️ Platform: ${platform.os}-${platform.arch}');
    
    String npxPath;
    switch (platform.os) {
      case 'windows':
        npxPath = '$basePath/${PathConstants.nodejsDirName}/${platform.os}/${platform.arch}/${PathConstants.nodeDirPrefix}${AppConstants.nodeVersion}/${PathConstants.npxExeName}${PathConstants.getScriptExtension()}';
        break;
      case 'macos':
      case 'linux':
        npxPath = '$basePath/${PathConstants.nodejsDirName}/${platform.os}/${platform.arch}/${PathConstants.nodeDirPrefix}${AppConstants.nodeVersion}/${PathConstants.nodeBinDir}/${PathConstants.npxExeName}';
        break;
      default:
        throw UnsupportedError('Unsupported platform: ${platform.os}');
    }
    
    print('   📦 NPX path: $npxPath');
    
    // 验证文件是否存在
    if (await File(npxPath).exists()) {
      print('   ✅ NPX executable found');
      
      // 测试npm exec功能（作为npx的替代）
      try {
        final npmPath = await getNpmExecutable();
        final result = await Process.run(npmPath, ['exec', '--help'], runInShell: true);
        if (result.exitCode == 0) {
          print('   ✅ npm exec is functional (NPX alternative working)');
        } else {
          print('   ⚠️ npm exec test failed (exit code: ${result.exitCode})');
        }
      } catch (e) {
        print('   ⚠️ Could not test npm exec functionality: $e');
      }
    } else {
      print('   ❌ NPX executable not found at expected path');
    }
    
    return npxPath;
  }

  /// 获取Corepack可执行文件路径
  Future<String> getCorepackExecutable() async {
    final basePath = await runtimeBasePath;
    final platform = _platformInfo;
    
    switch (platform.os) {
      case 'windows':
        return '$basePath/${PathConstants.nodejsDirName}/${platform.os}/${platform.arch}/${PathConstants.nodeDirPrefix}${AppConstants.nodeVersion}/${PathConstants.corepackExeName}${PathConstants.getScriptExtension()}';
      case 'macos':
      case 'linux':
        return '$basePath/${PathConstants.nodejsDirName}/${platform.os}/${platform.arch}/${PathConstants.nodeDirPrefix}${AppConstants.nodeVersion}/${PathConstants.nodeBinDir}/${PathConstants.corepackExeName}';
      default:
        throw UnsupportedError('Unsupported platform: ${platform.os}');
    }
  }

  /// 验证Python运行时是否可用
  Future<bool> validatePythonRuntime() async {
    try {
      final pythonExe = await getPythonExecutable();
      final result = await Process.run(pythonExe, ['--version']);
      return result.exitCode == 0 && result.stdout.toString().contains(AppConstants.pythonVersion);
    } catch (e) {
      return false;
    }
  }

  /// 验证UV工具是否可用
  Future<bool> validateUvRuntime() async {
    try {
      final uvExe = await getUvExecutable();
      final result = await Process.run(uvExe, ['--version']);
      return result.exitCode == 0 && result.stdout.toString().contains(AppConstants.uvVersion);
    } catch (e) {
      return false;
    }
  }

  /// 验证Node.js运行时是否可用
  Future<bool> validateNodeRuntime() async {
    try {
      final nodeExe = await getNodeExecutable();
      final result = await Process.run(nodeExe, ['--version']);
      return result.exitCode == 0 && result.stdout.toString().contains(AppConstants.nodeVersion);
    } catch (e) {
      return false;
    }
  }

  /// 验证所有运行时是否可用
  Future<Map<String, bool>> validateAllRuntimes() async {
    final results = <String, bool>{};
    
    results['python'] = await validatePythonRuntime();
    results['uv'] = await validateUvRuntime();
    results['node'] = await validateNodeRuntime();
    
    return results;
  }

  /// 获取运行时信息
  Future<Map<String, dynamic>> getRuntimeInfo() async {
    final info = <String, dynamic>{};
    
    info['platform'] = _platformInfo.toString();
    info['platformDescription'] = PlatformDetector.platformDescription;
    info['basePath'] = await runtimeBasePath;
    
    // 获取可执行文件路径
    info['executables'] = {
      'python': await getPythonExecutable(),
      'pip': await getPipExecutable(),
      'uv': await getUvExecutable(),
      'uvx': await getUvxExecutable(),
      'node': await getNodeExecutable(),
      'npm': await getNpmExecutable(),
      'npx': await getNpxExecutable(),
      'corepack': await getCorepackExecutable(),
    };
    
    // 验证运行时
    info['validation'] = await validateAllRuntimes();
    
    return info;
  }

  /// 重置运行时管理器（主要用于测试）
  void reset() {
    _runtimeBasePath = null;
  }

  /// 获取运行时基础路径（同步方法）
  String getRuntimeBasePath() {
    if (_runtimeBasePath != null) return _runtimeBasePath!;
    _runtimeBasePath = PathConstants.getUserRuntimesPath();
    return _runtimeBasePath!;
  }

  /// 获取平台标识字符串（如 'windows/x64'）
  String getPlatformString() {
    return '${_platformInfo.os}/${_platformInfo.arch}';
  }
} 