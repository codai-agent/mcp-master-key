import 'dart:io';

import '../../core/constants/app_constants.dart';
import 'platform_info.dart';
import 'runtime_manager.dart';
import 'asset_extractor.dart';

/// 运行时初始化器
class RuntimeInitializer {
  static RuntimeInitializer? _instance;
  late final RuntimeManager _runtimeManager;
  late final AssetExtractor _assetExtractor;
  bool _isInitialized = false;

  RuntimeInitializer._internal() {
    _runtimeManager = RuntimeManager.instance;
    _assetExtractor = AssetExtractor.instance;
  }

  /// 获取单例实例
  static RuntimeInitializer get instance {
    _instance ??= RuntimeInitializer._internal();
    return _instance!;
  }

  /// 初始化所有运行时环境
  Future<bool> initializeAllRuntimes() async {
    if (_isInitialized) {
      return true;
    }

    try {
      // 检查平台是否支持
      if (!PlatformDetector.isSupportedPlatform) {
        throw UnsupportedError('Current platform is not supported: ${PlatformDetector.platformDescription}');
      }

      print('Platform: ${PlatformDetector.platformDescription}');

      // 获取运行时基础路径
      final basePath = await _runtimeManager.runtimeBasePath;
      print('Runtime base path: $basePath');

      // 检查是否需要提取资源
      final isExtracted = await _assetExtractor.isRuntimeExtracted(basePath);
      print('Runtime already extracted: $isExtracted');

      if (!isExtracted) {
        print('🔄 Extracting runtime assets...');
        await _assetExtractor.extractAllRuntimes(basePath);
        print('✅ Runtime assets extracted successfully');
      } else {
        print('✅ Runtime assets already extracted');
      }

      // 验证运行时环境
      print('Validating runtime environments...');
      final validationResults = await _validateRuntimes();
      print('Runtime validation results: $validationResults');

      // 检查是否所有运行时都可用
      final allValid = validationResults.values.every((isValid) => isValid);
      if (!allValid) {
        print('Warning: Some runtimes are not available');
        _printDetailedValidationResults(validationResults);
      } else {
        print('All runtimes are available and validated');
      }

      _isInitialized = true;
      return true;
    } catch (e) {
      print('Failed to initialize runtimes: $e');
      return false;
    }
  }

  /// 验证所有运行时
  Future<Map<String, bool>> _validateRuntimes() async {
    final results = <String, bool>{};
    
    results['python'] = await _validatePythonRuntime();
    results['uv'] = await _validateUvRuntime();
    results['node'] = await _validateNodeRuntime();
    
    return results;
  }

  /// 验证Python运行时
  Future<bool> _validatePythonRuntime() async {
    try {
      final pythonExe = await _runtimeManager.getPythonExecutable();
      print('Checking Python at: $pythonExe');
      
      // 检查文件是否存在
      final file = File(pythonExe);
      if (!await file.exists()) {
        print('Python executable not found at: $pythonExe');
        return false;
      }
      
      final result = await Process.run(pythonExe, ['--version']);
      final isValid = result.exitCode == 0 && result.stdout.toString().contains(AppConstants.pythonVersion);
      
      if (isValid) {
        print('Python runtime is valid: ${result.stdout.toString().trim()}');
      } else {
        print('Python runtime validation failed: exit code ${result.exitCode}');
        print('stdout: ${result.stdout}');
        print('stderr: ${result.stderr}');
      }
      
      return isValid;
    } catch (e) {
      print('Error validating Python runtime: $e');
      return false;
    }
  }

  /// 验证UV工具
  Future<bool> _validateUvRuntime() async {
    try {
      final uvExe = await _runtimeManager.getUvExecutable();
      print('Checking UV at: $uvExe');
      
      // 检查文件是否存在
      final file = File(uvExe);
      if (!await file.exists()) {
        print('UV executable not found at: $uvExe');
        return false;
      }
      
      final result = await Process.run(uvExe, ['--version']);
      final isValid = result.exitCode == 0 && result.stdout.toString().contains(AppConstants.uvVersion);
      
      if (isValid) {
        print('UV runtime is valid: ${result.stdout.toString().trim()}');
      } else {
        print('UV runtime validation failed: exit code ${result.exitCode}');
        print('stdout: ${result.stdout}');
        print('stderr: ${result.stderr}');
      }
      
      return isValid;
    } catch (e) {
      print('Error validating UV runtime: $e');
      return false;
    }
  }

  /// 验证Node.js运行时
  Future<bool> _validateNodeRuntime() async {
    try {
      final nodeExe = await _runtimeManager.getNodeExecutable();
      print('Checking Node.js at: $nodeExe');
      
      // 检查文件是否存在
      final file = File(nodeExe);
      if (!await file.exists()) {
        print('Node.js executable not found at: $nodeExe');
        return false;
      }
      
      final result = await Process.run(nodeExe, ['--version']);
      final isValid = result.exitCode == 0 && result.stdout.toString().contains(AppConstants.nodeVersion);
      
      if (isValid) {
        print('Node.js runtime is valid: ${result.stdout.toString().trim()}');
      } else {
        print('Node.js runtime validation failed: exit code ${result.exitCode}');
        print('stdout: ${result.stdout}');
        print('stderr: ${result.stderr}');
      }
      
      return isValid;
    } catch (e) {
      print('Error validating Node.js runtime: $e');
      return false;
    }
  }

  /// 打印详细的验证结果
  void _printDetailedValidationResults(Map<String, bool> results) async {
    print('\n=== Detailed Runtime Validation Results ===');
    
    for (final entry in results.entries) {
      final runtime = entry.key;
      final isValid = entry.value;
      
      print('$runtime: ${isValid ? "✅ VALID" : "❌ INVALID"}');
      
      if (!isValid) {
        try {
          String exePath;
          switch (runtime) {
            case 'python':
              exePath = await _runtimeManager.getPythonExecutable();
              break;
            case 'uv':
              exePath = await _runtimeManager.getUvExecutable();
              break;
            case 'node':
              exePath = await _runtimeManager.getNodeExecutable();
              break;
            default:
              continue;
          }
          
          final file = File(exePath);
          final exists = await file.exists();
          print('  Path: $exePath');
          print('  Exists: $exists');
          
          if (exists) {
            final stat = await file.stat();
            print('  Size: ${stat.size} bytes');
            print('  Modified: ${stat.modified}');
          }
        } catch (e) {
          print('  Error getting details: $e');
        }
      }
    }
    print('===========================================\n');
  }

  /// 获取运行时状态
  Future<Map<String, dynamic>> getRuntimeStatus() async {
    final status = <String, dynamic>{};
    
    status['initialized'] = _isInitialized;
    status['platform'] = PlatformDetector.current.toString();
    status['platformSupported'] = PlatformDetector.isSupportedPlatform;
    
    if (_isInitialized) {
      status['validation'] = await _validateRuntimes();
      status['runtimeInfo'] = await _runtimeManager.getRuntimeInfo();
    }
    
    return status;
  }

  /// 重置初始化状态
  void reset() {
    _isInitialized = false;
  }

  /// 检查是否已初始化
  bool get isInitialized => _isInitialized;
} 