import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as path;
import '../../infrastructure/runtime/runtime_manager.dart';
import '../../core/models/mcp_server.dart';

/// 命令解析服务 - 将用户输入的命令转换为内置runtime的完整路径
class CommandResolverService {
  static CommandResolverService? _instance;
  final RuntimeManager _runtimeManager = RuntimeManager.instance;

  CommandResolverService._internal();

  /// 获取单例实例
  static CommandResolverService get instance {
    _instance ??= CommandResolverService._internal();
    return _instance!;
  }

  /// 解析并转换命令为内置runtime路径
  /// 
  /// 参数：
  /// - command: 用户输入的命令（如 'npx', 'uvx', 'python', 'node'）
  /// - installType: 安装类型
  /// 
  /// 返回转换后的完整可执行文件路径//huqb
  Future<String> resolveCommand({
    required String command, 
    required McpInstallType installType,
  }) async {
    print('🔧 Resolving command: $command (type: ${installType.name})');
    
    switch (installType) {
      case McpInstallType.npx:
        if (command == 'npx') {
          // 使用npm exec代替npx来避免路径问题
          final npmPath = await _runtimeManager.getNpmExecutable();
          print('   ✅ Resolved npx -> npm exec ($npmPath)');
          return npmPath;
        } else if (command == 'node') {
          final nodePath = await _runtimeManager.getNodeExecutable();
          print('   ✅ Resolved node -> $nodePath');
          return nodePath;
        } else if (command == 'npm') {
          final npmPath = await _runtimeManager.getNpmExecutable();
          print('   ✅ Resolved npm -> $npmPath');
          return npmPath;
        }
        break;
        
      case McpInstallType.uvx:
        if (command == 'uvx') {
          final uvxPath = await _runtimeManager.getUvxExecutable();
          print('   ✅ Resolved uvx -> $uvxPath');
          return uvxPath;
        } else if (command == 'uv') {
          final uvPath = await _runtimeManager.getUvExecutable();
          print('   ✅ Resolved uv -> $uvPath');
          return uvPath;
        } else if (command == 'python' || command == 'python3') {
          final pythonPath = await _runtimeManager.getPythonExecutable();
          print('   ✅ Resolved python -> $pythonPath');
          return pythonPath;
        } else if (command == 'pip' || command == 'pip3') {
          final pipPath = await _runtimeManager.getPipExecutable();
          print('   ✅ Resolved pip -> $pipPath');
          return pipPath;
        }
        break;
      
      case McpInstallType.smithery:
        // Smithery安装类型处理
        print('   ℹ️ Smithery command kept as-is: $command');
        return command;
        
      case McpInstallType.localPython:
        // 本地Python包处理
        if (command == 'python' || command == 'python3') {
          final pythonPath = await _runtimeManager.getPythonExecutable();
          print('   ✅ Resolved python for local Python package -> $pythonPath');
          return pythonPath;
        }
        break;
        
      case McpInstallType.localJar:
        // 本地JAR包处理
        if (command == 'java') {
          print('   ℹ️ Java command kept as-is: $command');
          return command;
        }
        break;
        
      case McpInstallType.localExecutable:
        // 本地可执行文件处理
        print('   ℹ️ Local executable command kept as-is: $command');
        return command;
        
      // 移除了老的localPath，现在使用具体的本地类型
        
      case McpInstallType.localNode:
       if (command == 'node') {
          final nodePath = await _runtimeManager.getNodeExecutable();
          print('   ✅ Resolved node for github project -> $nodePath');
          return nodePath;
        }
        break;
        
      case McpInstallType.preInstalled:
        // 预安装的命令通常不需要转换，但也可能需要解析
        print('   ℹ️ Pre-installed command kept as-is: $command');
        return command;
    }
    
    // 如果没有匹配的内置runtime，返回原命令（可能是系统命令）
    print('   ⚠️ No internal runtime match, keeping original command: $command');
    return command;
  }

  /// 批量解析命令参数中的runtime引用
  /// 某些参数可能也包含需要解析的命令（虽然不常见）
  Future<List<String>> resolveArgs({
    required List<String> args,
    required McpInstallType installType,
    required String originalCommand,
  }) async {
    print('🔧 Resolving command arguments...');
    print('   📋 Original args: ${args.join(' ')}');
    print('   📋 Install type: ${installType.name}');
    print('   📋 Original command: $originalCommand');
    
    // NPX命令处理 - 使用npm exec代替npx
    if (installType == McpInstallType.npx && originalCommand == 'npx') {
      print('   📦 Converting NPX to npm exec');
      final npmExecArgs = ['exec', ...args];
      print('   ✅ NPX args converted to npm exec: ${npmExecArgs.join(' ')}');
      return npmExecArgs;
    }
    
    // 大多数情况下参数不需要解析，直接返回
    print('   ✅ Args resolved (no changes needed): ${args.join(' ')}');
    return args;
  }

  /// 解析环境变量中的runtime路径
  Future<Map<String, String>> resolveEnvironment({
    required Map<String, String> env,
    required McpInstallType installType,
  }) async {
    final resolvedEnv = Map<String, String>.from(env);
    
    // 添加内置runtime到PATH环境变量
    try {
      final runtimePaths = <String>[];
      
      // 添加Node.js相关路径
      if (installType == McpInstallType.npx) {
        final nodeExe = await _runtimeManager.getNodeExecutable();
        final nodeBinDir = nodeExe.substring(0, nodeExe.lastIndexOf('/'));
        runtimePaths.add(nodeBinDir);
      }
      
      // 添加Python相关路径
      if (installType == McpInstallType.uvx) {
        final pythonExe = await _runtimeManager.getPythonExecutable();
        final pythonBinDir = pythonExe.substring(0, pythonExe.lastIndexOf('/'));
        runtimePaths.add(pythonBinDir);
        
        final uvExe = await _runtimeManager.getUvExecutable();
        final uvBinDir = uvExe.substring(0, uvExe.lastIndexOf('/'));
        runtimePaths.add(uvBinDir);
      }
      
      // 更新PATH环境变量
      if (runtimePaths.isNotEmpty) {
        final currentPath = resolvedEnv['PATH'] ?? '';
        final newPaths = runtimePaths.join(':');
        resolvedEnv['PATH'] = currentPath.isEmpty ? newPaths : '$newPaths:$currentPath';
        print('   🌍 Updated PATH with runtime directories: $newPaths');
      }
      
    } catch (e) {
      print('   ⚠️ Warning: Failed to resolve runtime paths for environment: $e');
    }
    
    return resolvedEnv;
  }

  /// 完整解析服务器配置
  /// 一次性解析命令、参数和环境变量
  Future<ResolvedServerConfig> resolveServerConfig({
    required String command,
    required List<String> args,
    required Map<String, String> env,
    required McpInstallType installType,
  }) async {
    print('🔧 Resolving complete server config...');
    print('   📋 Original command: $command');
    print('   📋 Original args: ${args.join(' ')}');
    print('   📋 Install type: ${installType.name}');
    
    final resolvedCommand = await resolveCommand(
      command: command, 
      installType: installType,
    );
    
    final resolvedArgs = await resolveArgs(
      args: args, 
      installType: installType,
      originalCommand: command,
    );
    
    final resolvedEnv = await resolveEnvironment(
      env: env, 
      installType: installType,
    );
    
    final resolved = ResolvedServerConfig(
      command: resolvedCommand,
      args: resolvedArgs,
      env: resolvedEnv,
    );
    
    print('   ✅ Resolved command: ${resolved.command}');
    print('   ✅ Resolved args: ${resolved.args.join(' ')}');
    print('   ✅ Resolved env keys: ${resolved.env.keys.join(', ')}');
    
    return resolved;
  }
}

/// 解析后的服务器配置
class ResolvedServerConfig {
  final String command;
  final List<String> args;
  final Map<String, String> env;

  const ResolvedServerConfig({
    required this.command,
    required this.args,
    required this.env,
  });

  @override
  String toString() {
    return 'ResolvedServerConfig(command: $command, args: ${args.join(' ')}, env: ${env.keys.join(', ')})';
  }
} 