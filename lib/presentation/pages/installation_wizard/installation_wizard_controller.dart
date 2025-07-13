import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../business/services/install_service.dart';
import '../../../business/services/mcp_server_service.dart';
import '../../../business/managers/install_managers/install_manager_interface.dart';

import '../../../core/models/mcp_server.dart';

import 'installation_wizard_models.dart';

/// 安装向导控制器
class InstallationWizardController extends ChangeNotifier {
  static final Map<String, dynamic> _persistentState = {};
  
  InstallationWizardState _state = const InstallationWizardState();
  Process? _currentInstallProcess;
  
  InstallationWizardState get state => _state;
  
  /// 检查是否有正在进行的安装
  static bool get hasActiveInstallation => _persistentState.isNotEmpty;
  
  /// 检查是否正在安装
  static bool get isInstalling => _persistentState['isInstalling'] == true;

  /// 初始化控制器
  void initialize() {
    _restoreState();
    if (_state.configText.isEmpty) {
      _updateState(_state.copyWith(
        configText: '''
{
  "mcpServers": {
  }
}''',
      ));
      parseConfig();
    }
  }

  /// 更新状态
  void _updateState(InstallationWizardState newState) {
    _state = newState;
    _saveState();
    notifyListeners();
  }

  /// 恢复保存的状态
  void _restoreState() {
    if (_persistentState.isNotEmpty) {
      print('🔄 恢复安装向导状态...');
      _state = InstallationWizardState.fromJson(_persistentState);
      
      // 检查进程状态
      if (_state.currentInstallProcessPid != null && _state.isInstalling) {
        _checkInstallProcessStatus(_state.currentInstallProcessPid!);
      }
    }
  }

  /// 保存当前状态
  void _saveState() {
    _persistentState.clear();
    _persistentState.addAll(_state.toJson());
    // 减少日志输出，避免重复保存信息
    // print('💾 安装向导状态已保存，当前步骤: ${_state.currentStep.index}');
  }

  /// 清除状态
  void clearState() {
    _persistentState.clear();
    print('🗑️ 安装完成，清除保存的状态');
  }

  /// 解析配置
  void parseConfig() {
    final configText = _state.configText.trim();
    if (configText.isEmpty) {
      _updateState(_state.copyWith(
        configError: '配置不能为空',
        parsedConfig: {},
      ));
      return;
    }

    try {
      final config = json.decode(configText);
      if (config is! Map<String, dynamic>) {
        _updateState(_state.copyWith(
          configError: '配置必须是一个JSON对象',
          parsedConfig: {},
        ));
        return;
      }

      if (!config.containsKey('mcpServers')) {
        _updateState(_state.copyWith(
          configError: '配置必须包含mcpServers字段',
          parsedConfig: {},
        ));
        return;
      }

      final mcpServers = config['mcpServers'];
      if (mcpServers is! Map<String, dynamic>) {
        _updateState(_state.copyWith(
          configError: 'mcpServers必须是一个对象',
          parsedConfig: {},
        ));
        return;
      }

      if (mcpServers.isEmpty) {
        _updateState(_state.copyWith(
          configError: 'mcpServers不能为空',
          parsedConfig: {},
        ));
        return;
      }

      // 分析安装策略
      final firstServer = mcpServers.values.first as Map<String, dynamic>;
      final command = firstServer['command'] as String?;
      
      if (command == null) {
        _updateState(_state.copyWith(
          configError: '服务器配置缺少command字段',
          parsedConfig: {},
        ));
        return;
      }

      // 清理配置
      Map<String, dynamic> cleanedConfig;
      try {
        cleanedConfig = _cleanupServerConfig(firstServer);
      } catch (e) {
        print('🔧 配置清理失败: $e');
        cleanedConfig = firstServer;
      }

      // 分析安装类型 可能不能只从command入手，如果是配置远程服务器，就不会有command命令 //huqb
      final cleanedCommand = cleanedConfig['command'] as String;
      McpInstallType? detectedType;
      bool needsAdditionalInstall = false;
      String analysisResult = '';

      if (cleanedCommand == 'uvx') {
        detectedType = McpInstallType.uvx;
        needsAdditionalInstall = false;
        analysisResult = '检测到UVX安装类型，可以自动安装';
      } else if (cleanedCommand == 'npx') {
        //进一步看是否是@smithery/cli
        if (isSmitheryCli(cleanedConfig)) {
          detectedType = McpInstallType.smithery;
          needsAdditionalInstall = false;
          analysisResult = '检测到smithery/cli安装类型，可以自动安装';
        } else {
          detectedType = McpInstallType.npx;
          needsAdditionalInstall = false;
          analysisResult = '检测到NPX安装类型，可以自动安装';
        }
      } else if (cleanedCommand == 'python' || cleanedCommand == 'python3') {
        detectedType = McpInstallType.localPython;
        needsAdditionalInstall = true;
        analysisResult = '检测到Python命令，需要手动配置安装';
      } else if (cleanedCommand == 'node') {
        detectedType = McpInstallType.npx;
        needsAdditionalInstall = true;
        analysisResult = '检测到Node.js命令，需要手动配置安装';
      } else {
        detectedType = McpInstallType.localExecutable;
        needsAdditionalInstall = true;
        analysisResult = '检测到自定义命令，需要手动配置安装';
      }

      _updateState(_state.copyWith(
        configError: '',
        parsedConfig: config,
        detectedInstallType: detectedType,
        needsAdditionalInstall: needsAdditionalInstall,
        analysisResult: analysisResult,
      ));

    } catch (e) {
      _updateState(_state.copyWith(
        configError: '配置解析失败: $e',
        parsedConfig: {},
      ));
    }
  }

  /// 是否为@smithery/cli包
  bool isSmitheryCli(Map<String, dynamic> serverConfig) {
    List<String> args = (serverConfig['args'] as List<dynamic>?)?.cast<String>() ?? [];
    if(args.isNotEmpty) {
      for (int i = 0; i < args.length; i++) {
        if (args[i].startsWith('@smithery/cli')) {
          return true;
        }
      }
    }
    return false;
  }

  /// 清理和规范化服务器配置，处理特殊格式的兼容性
  Map<String, dynamic> _cleanupServerConfig(Map<String, dynamic> serverConfig) {
    final cleanedConfig = Map<String, dynamic>.from(serverConfig);
    String? commandValue = cleanedConfig['command'];
    if (commandValue == null) {
      throw Exception('服务器配置缺少command字段');
    }
    String command = commandValue;
    List<String> args = (cleanedConfig['args'] as List<dynamic>?)?.cast<String>() ?? [];
    
    // 处理Windows cmd命令
    if (command == 'cmd' && args.isNotEmpty) {
      if (args[0] == '/c' && args.length > 1) {
        command = args[1];
        args = args.sublist(2);
        print('🔧 检测到Windows cmd格式，提取实际命令: $command');
      }
    }
    
    // // 处理@smithery/cli的特殊NPX格式
    // if (command == 'npx' && args.isNotEmpty) {
    //   int smitheryIndex = -1;
    //   for (int i = 0; i < args.length; i++) {
    //     if (args[i].startsWith('@smithery/cli')) {
    //       smitheryIndex = i;
    //       break;
    //     }
    //   }
    //
    //   if (smitheryIndex != -1) {
    //     print('🔧 检测到@smithery/cli格式，需要清理参数');
    //
    //     final List<String> cleanedArgs = [];
    //     bool skipNext = false;
    //     bool foundSmithery = false;
    //
    //     for (int i = 0; i < args.length; i++) {
    //       if (skipNext) {
    //         skipNext = false;
    //         continue;
    //       }
    //
    //       final arg = args[i];
    //
    //       if (arg.startsWith('@smithery/cli')) {
    //         foundSmithery = true;
    //         continue;
    //       }
    //
    //       if (foundSmithery && (arg == 'run' || arg == 'inspect')) {
    //         foundSmithery = false;
    //         continue;
    //       }
    //
    //       if (arg == '--key') {
    //         skipNext = true;
    //         continue;
    //       }
    //
    //       cleanedArgs.add(arg);
    //       foundSmithery = false;
    //     }
    //
    //     args = cleanedArgs;
    //   }
    // }
    //
    // // 处理UVX命令
    // if (command == 'uvx' && args.isNotEmpty) {
    //   final List<String> cleanedArgs = [];
    //   bool skipNext = false;
    //
    //   for (int i = 0; i < args.length; i++) {
    //     if (skipNext) {
    //       skipNext = false;
    //       continue;
    //     }
    //
    //     final arg = args[i];
    //
    //     if (arg == '--key') {
    //       skipNext = true;
    //       continue;
    //     }
    //
    //     cleanedArgs.add(arg);
    //   }
    //
    //   if (cleanedArgs.length != args.length) {
    //     print('🔧 UVX清理--key参数');
    //     args = cleanedArgs;
    //   }
    // }
    
    cleanedConfig['command'] = command;
    cleanedConfig['args'] = args;
    
    return cleanedConfig;
  }

  /// 解析命令并生成配置
  void parseCommand(String command) {
    if (command.trim().isEmpty) return;
    
    try {
      final config = _parseCommandToConfig(command);
      if (config != null) {
        _updateState(_state.copyWith(configText: config));
        parseConfig();
      }
    } catch (e) {
      print('命令解析失败：$e');
    }
  }

  /// 将命令解析为MCP配置
  String? _parseCommandToConfig(String command) {
    final parts = _splitCommand(command);
    if (parts.isEmpty) return null;
    
    String cmd = parts[0];
    List<String> args = parts.sublist(1);
    
    if (cmd == 'npx' || cmd == 'uvx') {
      final cleanedArgs = _cleanCommandArgs(cmd, args);
      String serverName = _extractServerName(cleanedArgs);
      
      final config = {
        'mcpServers': {
          serverName: {
            'command': cmd,
            'args': cleanedArgs,
          }
        }
      };
      
      return const JsonEncoder.withIndent('  ').convert(config);
    }
    
    return null;
  }

  /// 分割命令字符串
  List<String> _splitCommand(String command) {
    final parts = <String>[];
    bool inQuotes = false;
    String current = '';
    
    for (int i = 0; i < command.length; i++) {
      final char = command[i];
      
      if (char == '"' || char == "'") {
        inQuotes = !inQuotes;
      } else if (char == ' ' && !inQuotes) {
        if (current.isNotEmpty) {
          parts.add(current);
          current = '';
        }
      } else {
        current += char;
      }
    }
    
    if (current.isNotEmpty) {
      parts.add(current);
    }
    
    return parts;
  }

  /// 清理命令参数
  List<String> _cleanCommandArgs(String command, List<String> args) {
    final cleanedArgs = <String>[];
    bool skipNext = false;
    bool foundSmithery = false;
    
    for (int i = 0; i < args.length; i++) {
      if (skipNext) {
        skipNext = false;
        continue;
      }
      
      final arg = args[i];
      
      if (arg.startsWith('@smithery/cli')) {
        foundSmithery = true;
        continue;
      }
      
      if (foundSmithery && (arg == 'run' || arg == 'inspect')) {
        foundSmithery = false;
        continue;
      }
      
      if (arg == '--key') {
        skipNext = true;
        continue;
      }
      
      cleanedArgs.add(arg);
      foundSmithery = false;
    }
    
    return cleanedArgs;
  }

  /// 提取服务器名称
  String _extractServerName(List<String> args) {
    if (args.isEmpty) return 'mcp-server';
    
    final packageName = args.first;
    if (packageName.contains('/')) {
      return packageName.split('/').last;
    }
    
    return packageName;
  }

  // 更新方法
  void updateConfigText(String value) {
    _updateState(_state.copyWith(configText: value));
  }

  void updateServerName(String value) {
    _updateState(_state.copyWith(serverName: value));
  }

  void updateServerDescription(String value) {
    _updateState(_state.copyWith(serverDescription: value));
  }

  void updateGithubUrl(String value) {
    _updateState(_state.copyWith(githubUrl: value));
  }

  void updateLocalPath(String value) {
    _updateState(_state.copyWith(localPath: value));
  }

  void updateInstallCommand(String value) {
    _updateState(_state.copyWith(installCommand: value));
  }

  void updateSelectedInstallType(String value) {
    _updateState(_state.copyWith(selectedInstallType: value));
  }

  /// 下一步
  void nextStep() {
    if (_state.currentStep.index < WizardStep.values.length - 1) {
      final nextStep = WizardStep.values[_state.currentStep.index + 1];
      _updateState(_state.copyWith(currentStep: nextStep));
    }
  }

  /// 上一步
  void previousStep() {
    if (_state.currentStep.index > 0) {
      final prevStep = WizardStep.values[_state.currentStep.index - 1];
      _updateState(_state.copyWith(currentStep: prevStep));
    }
  }

  /// 自动进行页面切换
  Future<void> autoAdvanceSteps() async {
    // 移除自动推进逻辑，让用户手动控制页面切换
    // 这样避免了状态混乱和重复保存的问题
  }

  /// 开始安装
  Future<void> startInstallation() async {
    _updateState(_state.copyWith(
      isInstalling: true,
      installationLogs: ['🚀 开始安装MCP服务器...'],
    ));

    try {
      final installService = InstallService.instance;
      final serverService = McpServerService.instance;
      
      // 检查配置是否有效
      if (_state.parsedConfig.isEmpty || !_state.parsedConfig.containsKey('mcpServers')) {
        throw Exception('配置无效：缺少mcpServers字段');
      }
      
      final mcpServersData = _state.parsedConfig['mcpServers'];
      if (mcpServersData == null || mcpServersData is! Map<String, dynamic>) {
        throw Exception('配置无效：mcpServers字段格式错误');
      }
      
      final mcpServers = mcpServersData as Map<String, dynamic>;
      if (mcpServers.isEmpty) {
        throw Exception('配置无效：mcpServers为空');
      }
      
      final serverName = mcpServers.keys.first;
      // 更新服务器名称
      updateServerName(serverName);
      _addLog('📝 服务器名称: $serverName');

      final originalServerConfigData = mcpServers[serverName];
      if (originalServerConfigData == null || originalServerConfigData is! Map<String, dynamic>) {
        throw Exception('配置无效：服务器配置格式错误');
      }
      
      final originalServerConfig = originalServerConfigData as Map<String, dynamic>;
      
      // 应用配置清理
      Map<String, dynamic> serverConfig;
      try {
        serverConfig = _cleanupServerConfig(originalServerConfig);
      } catch (e) {
        print('🔧 配置清理失败: $e');
        serverConfig = originalServerConfig;
      }
      
      _addLog('📋 解析服务器配置: $serverName');
      _addLog('📋 原始命令: ${originalServerConfig['command']}');
      _addLog('📋 原始参数: ${originalServerConfig['args']}');
      
      if (serverConfig['command'] != originalServerConfig['command'] || 
          serverConfig['args'].toString() != originalServerConfig['args'].toString()) {
        _addLog('🔧 检测到特殊格式，已自动清理:');
        _addLog('📋 清理后命令: ${serverConfig['command']}');
        _addLog('📋 清理后参数: ${serverConfig['args']}');
      }
      
      // 确定安装类型
      final installType = _state.detectedInstallType!;
              _addLog('🔧 安装类型: ${installType.name}');
        
        // 获取包名和服务器名称
        final args = (serverConfig['args'] as List?)?.cast<String>() ?? [];
        
        // 尝试从配置中获取服务器名称
        final configName = serverConfig['name'] as String?;
        if (configName != null && configName.isNotEmpty) {
          // 更新服务器名称
          updateServerName(configName);
          _addLog('📝 服务器名称: $configName');
        }
        
        // 使用服务器名称作为包名
        String packageName = serverName;
        
        _addLog('📦 包名: $packageName');
      _addLog('🔄 开始实际安装过程...');
      
      // 创建临时服务器对象用于安装
      final tempServer = McpServer(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        name: packageName,
        command: serverConfig['command'],
        args: args,
        env: Map<String, String>.from(serverConfig['env'] ?? {}),
        installType: installType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // 执行安装
      final result = await installService.installServerCancellable(
        tempServer,
        onProcessStarted: (process) {
          // 保存进程引用，用于取消
          _currentInstallProcess = process;
          _updateState(_state.copyWith(
            currentInstallProcessPid: process.pid,
          ));
          _addLog('🔧 安装进程已启动 (PID: ${process.pid})');
        },
      );
      
      if (result.success) {
        final isAlreadyInstalled = result.output?.contains('already installed') ?? false;
        
        if (isAlreadyInstalled) {
          _addLog('✅ 包已安装！');
          _addLog('🔍 检查是否已存在相同的服务器配置...');
        } else {
          _addLog('✅ 包安装成功！');
        }
        
        _addLog('📦 正在添加服务器到MCP Hub...');
        
        // 添加到服务器列表
        try {
          await serverService.addServer(
            name: _state.serverName.isNotEmpty ? _state.serverName : serverName,
            description: _state.serverDescription,
            command: serverConfig['command'],
            args: args,
            env: Map<String, String>.from(serverConfig['env'] ?? {}),
            installType: installType,
            autoStart: false,
          );
          
          _addLog('✅ 服务器添加成功！');
          _addLog('🎯 安装完成，可以在服务器列表中启动该服务器');
          
          // 查找刚添加的服务器并更新状态
          try {
            final allServers = await serverService.getAllServers();
            final addedServer = allServers.firstWhere(
              (s) => s.name == (_state.serverName.isNotEmpty ? _state.serverName : serverName),
              orElse: () => throw Exception('无法找到刚添加的服务器'),
            );
            
            await serverService.updateServerStatus(addedServer.id, McpServerStatus.installed);
            _addLog('✅ 服务器状态已更新为已安装');
            
            // 等待一下确保状态更新完成
            await Future.delayed(const Duration(milliseconds: 1000));
            _addLog('✅ 状态同步完成，可以在服务器列表中启动该服务器');
            
          } catch (e) {
            _addLog('⚠️ 警告：无法更新服务器状态: $e');
            _addLog('✅ 但服务器已成功添加，可以手动启动');
          }
          
        } catch (e) {
          // 检查是否是重复服务器的错误
          if (e.toString().contains('已存在')) {
            final errorMessage = e.toString();
            _addLog('⚠️ $errorMessage');
            
            if (isAlreadyInstalled) {
              _addLog('✅ 服务器包已安装，现有服务器配置完全匹配');
              _addLog('💡 提示：可以直接在服务器列表中使用现有服务器');
            } else {
              _addLog('✅ 包安装成功，但服务器配置已存在');
              _addLog('💡 提示：可能之前已添加过相同的服务器');
            }
            
            // 查找现有服务器并确保其状态正确
            try {
              final allServers = await serverService.getAllServers();
              
              // 尝试多种方式查找现有服务器
              final existingServer = allServers.firstWhere(
                (s) => s.name.toLowerCase().contains(packageName.toLowerCase()) || 
                       (s.installSource != null && s.installSource!.contains(packageName)) ||
                       s.command == serverConfig['command'],
                orElse: () => throw Exception('无法找到现有服务器'),
              );
              
              _addLog('🔍 找到现有服务器: ${existingServer.name} (状态: ${existingServer.status.name})');
              
              if (existingServer.status == McpServerStatus.notInstalled) {
                await serverService.updateServerStatus(existingServer.id, McpServerStatus.installed);
                _addLog('✅ 已更新现有服务器状态为已安装');
              } else {
                _addLog('✅ 现有服务器状态正常');
              }
              
            } catch (findError) {
              _addLog('⚠️ 无法自动定位现有服务器，请手动检查服务器列表');
              _addLog('💡 查找失败原因: $findError');
            }
          } else {
            _addLog('❌ 添加服务器失败: $e');
            _updateState(_state.copyWith(
              isInstalling: false,
              installationSuccess: false,
              currentInstallProcessPid: null,
            ));
            return;
          }
        }
        
        _updateState(_state.copyWith(
          installationSuccess: true,
          isInstalling: false,
          currentInstallProcessPid: null,
        ));
        
      } else {
        _addLog('❌ 安装失败: ${result.errorMessage ?? '未知错误'}');
        _updateState(_state.copyWith(
          isInstalling: false,
          installationSuccess: false,
          currentInstallProcessPid: null,
        ));
      }
      
    } catch (e) {
      _addLog('❌ 安装失败: $e');
      _addLog('🔍 错误详情: ${e.toString()}');
      _updateState(_state.copyWith(
        isInstalling: false,
        installationSuccess: false,
        currentInstallProcessPid: null,
      ));
    }
  }

  /// 添加日志
  void _addLog(String message) {
    final logs = List<String>.from(_state.installationLogs);
    logs.add(message);
    _updateState(_state.copyWith(installationLogs: logs));
  }

  /// 显示取消安装确认对话框
  Future<bool?> showCancelInstallDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('取消安装'),
            ],
          ),
          content: const Text('检测到正在进行安装过程。\n\n如果取消，当前安装的进程将被终止，已下载的内容可能需要重新开始。\n\n您确定要取消安装吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('继续安装'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('取消安装'),
            ),
          ],
        );
      },
    );
  }

  /// 取消安装
  Future<void> cancelInstallation() async {
    if (_currentInstallProcess != null) {
      _addLog('🔪 正在取消安装进程...');
      InstallManagerInterface.killProcessCrossPlatform(_currentInstallProcess!);
      _currentInstallProcess = null;
    } else if (_state.currentInstallProcessPid != null) {
      _addLog('🔪 正在通过PID取消安装进程...');
      InstallManagerInterface.killProcessByPid(_state.currentInstallProcessPid!);
    }
    
    _addLog('🚫 安装已取消');
    _updateState(_state.copyWith(
      isInstalling: false,
      installationSuccess: false,
      currentInstallProcessPid: null,
    ));
  }

  /// 通过PID杀死进程 (保留作为后备方法)
  void _killProcessById(int pid) {
    try {
      print('🔪 正在取消安装进程 $pid...');
      InstallManagerInterface.killProcessByPid(pid);
      
      _addLog('🚫 安装已取消');
      _updateState(_state.copyWith(
        isInstalling: false,
        installationSuccess: false,
        currentInstallProcessPid: null,
      ));
      
    } catch (e) {
      _addLog('❌ 取消安装进程失败: $e');
    }
  }

  /// 检查安装进程状态
  void _checkInstallProcessStatus(int pid) async {
    try {
      ProcessResult result;
      if (Platform.isWindows) {
        result = await Process.run('tasklist', ['/FI', 'PID eq $pid']);
      } else {
        result = await Process.run('ps', ['-p', '$pid']);
      }
      
      if (result.exitCode == 0 && result.stdout.toString().contains('$pid')) {
        _addLog('🔄 检测到之前的安装进程仍在运行...');
      } else {
        _addLog('⚠️ 之前的安装进程已结束');
        _updateState(_state.copyWith(
          isInstalling: false,
          currentInstallProcessPid: null,
        ));
      }
    } catch (e) {
      _addLog('⚠️ 无法检查安装进程状态，假设已结束');
      _updateState(_state.copyWith(
        isInstalling: false,
        currentInstallProcessPid: null,
      ));
    }
  }

  /// 验证安装选项
  bool validateInstallOptions() {
    if (!_state.needsAdditionalInstall) return true;
    
    if (_state.selectedInstallType == 'github') {
      return _state.githubUrl.isNotEmpty;
    } else if (_state.selectedInstallType == 'local') {
      return _state.localPath.isNotEmpty;
    }
    return false;
  }

  @override
  void dispose() {
    super.dispose();
  }
} 