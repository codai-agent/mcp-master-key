import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import '../../business/services/package_manager_service.dart';
import '../../business/services/mcp_server_service.dart';
import '../../business/parsers/mcp_config_parser.dart';
import '../../core/models/mcp_server.dart';
import '../../infrastructure/runtime/runtime_manager.dart';
import '../widgets/json_config_editor.dart';
import '../../l10n/generated/app_localizations.dart';
import 'home_page.dart';

/// 安装向导页面
class InstallationWizardPage extends StatefulWidget {
  const InstallationWizardPage({super.key});

  /// 检查是否有正在进行的安装
  static bool get hasActiveInstallation {
    return _InstallationWizardPageState._persistentState.isNotEmpty;
  }

  /// 检查是否正在安装
  static bool get isInstalling {
    final state = _InstallationWizardPageState._persistentState;
    return state['isInstalling'] == true;
  }

  @override
  State<InstallationWizardPage> createState() => _InstallationWizardPageState();
}

class _InstallationWizardPageState extends State<InstallationWizardPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // 第一步：MCP服务器配置
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _configController = TextEditingController();
  final TextEditingController _commandController = TextEditingController(); // 命令解析输入框
  String _configError = '';
  Map<String, dynamic> _parsedConfig = {};
  
  // 第二步：安装策略分析结果
  InstallStrategy? _detectedStrategy;
  bool _needsAdditionalInstall = false;
  String _analysisResult = '';
  
  // 第三步：额外安装选项（如果需要）
  String _selectedInstallType = 'github';
  final TextEditingController _githubUrlController = TextEditingController();
  final TextEditingController _localPathController = TextEditingController();
  final TextEditingController _installCommandController = TextEditingController();
  
  // 第四步：安装执行
  bool _isInstalling = false;
  List<String> _installationLogs = [];
  bool _installationSuccess = false;
  
  // 自动切换状态
  bool _isAutoAdvancing = false;
  
  // 安装进程控制
  Process? _currentInstallProcess;
  int? _currentInstallProcessPid; // 保存进程ID用于状态恢复
  
  // 🔥 简单的内存中状态保持
  static final Map<String, dynamic> _persistentState = {};

  @override
  void initState() {
    super.initState();
    
    // 🔄 恢复保存的状态（如果有的话）
    _restoreState();
    
    // 如果没有保存的状态，初始化为空配置
    if (_configController.text.isEmpty) {
      _configController.text = '''
{
  "mcpServers": {
  }
}''';
      _parseConfig();
    }
  }

  /// 恢复保存的状态
  void _restoreState() {
    if (_persistentState.isNotEmpty) {
      print('🔄 恢复安装向导状态...');
      
      setState(() {
        _currentStep = _persistentState['currentStep'] ?? 0;
        _configError = _persistentState['configError'] ?? '';
        _parsedConfig = Map<String, dynamic>.from(_persistentState['parsedConfig'] ?? {});
        _needsAdditionalInstall = _persistentState['needsAdditionalInstall'] ?? false;
        _analysisResult = _persistentState['analysisResult'] ?? '';
        _selectedInstallType = _persistentState['selectedInstallType'] ?? 'github';
        _isInstalling = _persistentState['isInstalling'] ?? false;
        _installationLogs = List<String>.from(_persistentState['installationLogs'] ?? []);
        _installationSuccess = _persistentState['installationSuccess'] ?? false;
        _isAutoAdvancing = _persistentState['isAutoAdvancing'] ?? false;
        
        // 恢复检测到的策略
        final strategyName = _persistentState['detectedStrategy'];
        if (strategyName != null) {
          _detectedStrategy = InstallStrategy.values.firstWhere(
            (s) => s.name == strategyName,
            orElse: () => InstallStrategy.uvx,
          );
        }
        
        // 恢复进程ID并检查进程是否仍在运行
        _currentInstallProcessPid = _persistentState['currentInstallProcessPid'];
        if (_currentInstallProcessPid != null && _isInstalling) {
          _checkInstallProcessStatus(_currentInstallProcessPid!);
        }
      });
      
      // 恢复控制器文本
      _nameController.text = _persistentState['serverName'] ?? '';
      _descriptionController.text = _persistentState['serverDescription'] ?? '';
      _configController.text = _persistentState['configText'] ?? '';
      _githubUrlController.text = _persistentState['githubUrl'] ?? '';
      _localPathController.text = _persistentState['localPath'] ?? '';
      
      // 恢复页面位置
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentStep > 0 && _currentStep < 4) {
          _pageController.animateToPage(
            _currentStep,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  /// 保存当前状态
  void _saveState() {
    _persistentState.clear();
    _persistentState.addAll({
      'currentStep': _currentStep,
      'configError': _configError,
      'parsedConfig': Map<String, dynamic>.from(_parsedConfig),
      'needsAdditionalInstall': _needsAdditionalInstall,
      'analysisResult': _analysisResult,
      'selectedInstallType': _selectedInstallType,
      'isInstalling': _isInstalling,
      'installationLogs': List<String>.from(_installationLogs),
      'installationSuccess': _installationSuccess,
      'isAutoAdvancing': _isAutoAdvancing,
      'detectedStrategy': _detectedStrategy?.name,
      'currentInstallProcessPid': _currentInstallProcessPid, // 保存进程ID
      
      // 控制器文本
      'serverName': _nameController.text,
      'serverDescription': _descriptionController.text,
      'configText': _configController.text,
      'githubUrl': _githubUrlController.text,
      'localPath': _localPathController.text,
    });
    
    print('💾 安装向导状态已保存，当前步骤: $_currentStep, 进程ID: $_currentInstallProcessPid');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.install_wizard_title),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          // 步骤指示器
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStepIndicator(0, l10n.install_wizard_step_configure, l10n.install_wizard_step_required),
                _buildStepConnector(),
                _buildStepIndicator(1, l10n.install_wizard_step_analyze, l10n.install_wizard_step_auto),
                _buildStepConnector(),
                _buildStepIndicator(2, l10n.install_wizard_step_options, l10n.install_wizard_step_optional),
                _buildStepConnector(),
                _buildStepIndicator(3, l10n.install_wizard_step_execute, l10n.install_wizard_step_complete),
              ],
            ),
          ),
          
          // 页面内容
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildConfigStep(l10n),
                _buildAnalysisStep(l10n),
                _buildInstallOptionsStep(l10n),
                _buildExecutionStep(l10n),
              ],
            ),
          ),
          
          // 底部按钮
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isAutoAdvancing ? null : _previousStep,
                      child: Text(l10n.common_previous),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _getNextButtonAction(),
                    child: Text(_getNextButtonText()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建步骤指示器
  Widget _buildStepIndicator(int step, String title, String subtitle) {
    final isActive = step <= _currentStep;
    final isCurrent = step == _currentStep;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive 
                ? Theme.of(context).primaryColor 
                : Colors.grey[300],
              border: isCurrent 
                ? Border.all(color: Theme.of(context).primaryColor, width: 3)
                : null,
            ),
            child: Center(
              child: Text(
                '${step + 1}',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Theme.of(context).primaryColor : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector() {
    return Container(
      width: 20,
      height: 2,
      color: Colors.grey[300],
      margin: const EdgeInsets.only(bottom: 40),
    );
  }

  // 第一步：配置MCP服务器
  Widget _buildConfigStep(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.install_wizard_configure_title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.install_wizard_configure_subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // 服务器名称
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.install_wizard_server_name,
              hintText: l10n.install_wizard_server_name_example,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          // 服务器描述
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.install_wizard_server_description,
              hintText: l10n.install_wizard_server_description_example,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          // MCP配置
          Text(
            l10n.install_wizard_server_config_title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          JsonConfigEditor(
            initialValue: _configController.text,
            onChanged: (newConfig) {
              _configController.text = newConfig;
              _parseConfig();
            },
            errorText: _configError.isNotEmpty ? _configError : null,
            placeholderText: '${l10n.install_wizard_config_placeholder}\n\n    "server-name": {\n        "command": "uvx",\n        "args": ["package-name"]\n    }',
          ),
          
          // 命令解析器
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commandController,
                  decoration: InputDecoration(
                    hintText: 'uvx/npx 安装命令',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.terminal),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _parseCommand,
                icon: const Icon(Icons.transform, size: 16),
                label: const Text('解析命令'),
              ),
            ],
          ),
          
          // // 配置帮助
          // Container(
          //   margin: const EdgeInsets.only(top: 8),
          //   padding: const EdgeInsets.all(12),
          //   decoration: BoxDecoration(
          //     color: Colors.blue[50],
          //     borderRadius: BorderRadius.circular(4),
          //     border: Border.all(color: Colors.blue[200]!),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Row(
          //         children: [
          //           Icon(Icons.info, size: 16, color: Colors.blue[700]),
          //           const SizedBox(width: 8),
          //           Text(
          //             '配置说明',
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //               color: Colors.blue[700],
          //             ),
          //           ),
          //         ],
          //       ),
          //       const SizedBox(height: 8),
          //                 Text(l10n.install_wizard_auto_install_note),
          // Text(l10n.install_wizard_manual_install_note),
          // Text(l10n.install_wizard_env_support_note),
          //     ],
          //   ),
          // ),
          
          // // 配置示例按钮
          // const SizedBox(height: 16),
          // Wrap(
          //   spacing: 8,
          //   children: [
          //     ElevatedButton.icon(
          //       onPressed: () => _loadExampleConfig('uvx'),
          //       icon: const Icon(Icons.code, size: 16),
          //       label: Text(l10n.install_wizard_uvx_example),
          //     ),
          //     ElevatedButton.icon(
          //       onPressed: () => _loadExampleConfig('npx'),
          //       icon: const Icon(Icons.code, size: 16),
          //       label: Text(l10n.install_wizard_npx_example),
          //     ),
          //     ElevatedButton.icon(
          //       onPressed: () => _loadExampleConfig('python'),
          //       icon: const Icon(Icons.code, size: 16),
          //       label: Text(l10n.install_wizard_python_example),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  // 第二步：分析安装策略
  Widget _buildAnalysisStep(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.install_wizard_analysis_title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.install_wizard_analysis_subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          if (_detectedStrategy != null) ...[
            // 分析结果
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        l10n.install_wizard_strategy_detected(_getStrategyDisplayName(_detectedStrategy!)),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_analysisResult),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // 是否需要额外安装
            if (_needsAdditionalInstall) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Text(
                          l10n.install_wizard_additional_steps_required,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.install_wizard_manual_config_note),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_fix_high, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          l10n.install_wizard_auto_install_ready,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.install_wizard_auto_config_note),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // 第三步：额外安装选项
  Widget _buildInstallOptionsStep(AppLocalizations l10n) {
    if (!_needsAdditionalInstall) {
              return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.skip_next, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                l10n.install_wizard_no_additional_config,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(l10n.install_wizard_auto_install_supported),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.install_wizard_config_source_title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.install_wizard_config_source_subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // 安装类型选择
          Text(
            l10n.install_wizard_source_type,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                RadioListTile<String>(
                                  title: Text(l10n.install_wizard_github_source),
                subtitle: Text(l10n.install_wizard_github_source_desc),
                  value: 'github',
                  groupValue: _selectedInstallType,
                  onChanged: (value) {
                    setState(() {
                      _selectedInstallType = value!;
                    });
                  },
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                                  title: Text(l10n.install_wizard_local_path),
                subtitle: Text(l10n.install_wizard_local_path_desc),
                  value: 'local',
                  groupValue: _selectedInstallType,
                  onChanged: (value) {
                    setState(() {
                      _selectedInstallType = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // 根据选择显示不同的配置选项
          if (_selectedInstallType == 'github') ...[
            TextField(
              controller: _githubUrlController,
              decoration: InputDecoration(
                labelText: l10n.install_wizard_github_repo_url,
                hintText: 'https://github.com/owner/repo',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_fix_high, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        l10n.install_wizard_auto_analysis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                                      Text(l10n.install_wizard_auto_analyze_note),
                ],
              ),
            ),
          ] else if (_selectedInstallType == 'local') ...[
            TextField(
              controller: _localPathController,
              decoration: InputDecoration(
                labelText: l10n.install_wizard_local_path_label,
                hintText: '/path/to/mcp-server',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.folder),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: () {
                    // TODO: 实现文件夹选择
                  },
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          TextField(
            controller: _installCommandController,
            decoration: InputDecoration(
              labelText: l10n.install_wizard_install_command,
              hintText: '例如：pip install -e . 或 npm install',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.terminal),
            ),
          ),
        ],
      ),
    );
  }

  // 第四步：
  Widget _buildExecutionStep(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.install_wizard_execution_title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _isInstalling 
              ? l10n.install_wizard_execution_installing
              : _installationSuccess
                ? l10n.install_wizard_install_complete
                : l10n.install_wizard_execution_ready,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // 安装摘要
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.install_wizard_execution_summary,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildSummaryItem(l10n.install_wizard_summary_server_name, _nameController.text.isNotEmpty ? _nameController.text : l10n.install_wizard_summary_unnamed),
                if (_descriptionController.text.isNotEmpty)
                  _buildSummaryItem(l10n.install_wizard_summary_description, _descriptionController.text),
                if (_detectedStrategy != null)
                  _buildSummaryItem(l10n.install_wizard_summary_strategy, _getStrategyDisplayName(_detectedStrategy!)),
                if (_needsAdditionalInstall)
                  _buildSummaryItem(l10n.install_wizard_summary_source, _selectedInstallType == 'github' ? l10n.install_wizard_source_github : l10n.install_wizard_source_local),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 安装日志
          if (_installationLogs.isNotEmpty) ...[
            Text(
              l10n.install_wizard_execution_logs,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              height: 180, // 减少高度以节省空间
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                itemCount: _installationLogs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      _installationLogs[index],
                      style: const TextStyle(
                        color: Colors.green,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2, // 减少最大行数
                    ),
                  );
                },
              ),
            ),
          ],
          
          if (_isInstalling) ...[
            const SizedBox(height: 12), // 减少间距
            const LinearProgressIndicator(),
          ],
          
          if (_installationSuccess) ...[
            const SizedBox(height: 12), // 减少间距
            Container(
              padding: const EdgeInsets.all(12), // 减少内边距
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 20), // 减少图标大小
                  const SizedBox(width: 8), // 减少间距
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.install_wizard_success_title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                            fontSize: 14, // 减少字体大小
                          ),
                        ),
                        Text(
                          l10n.install_wizard_success_message,
                          style: const TextStyle(fontSize: 12), // 减少字体大小
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // 额外的底部间距，确保内容不会被按钮遮挡
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // 解析配置
  void _parseConfig() {
    setState(() {
      _configError = '';
      _parsedConfig = {};
    });
    
    try {
      final config = json.decode(_configController.text);
      if (config is! Map<String, dynamic>) {
        throw const FormatException('配置必须是JSON对象');
      }
      
      if (!config.containsKey('mcpServers')) {
        throw const FormatException('配置中必须包含mcpServers字段');
      }
      
      final mcpServers = config['mcpServers'];
      if (mcpServers is! Map<String, dynamic>) {
        throw const FormatException('mcpServers必须是对象类型');
      }
      
      if (mcpServers.isEmpty) {
        throw const FormatException('mcpServers不能为空');
      }
      
      // 验证每个服务器配置
      for (final entry in mcpServers.entries) {
        final serverConfig = entry.value;
        if (serverConfig is! Map<String, dynamic>) {
          throw FormatException('服务器配置"${entry.key}"必须是对象类型');
        }
        
        if (!serverConfig.containsKey('command')) {
          throw FormatException('服务器配置"${entry.key}"缺少command字段');
        }
      }
      
      setState(() {
        _parsedConfig = config;
      });
      
      // 分析安装策略
      _analyzeInstallStrategy(AppLocalizations.of(context)!);
      
    } catch (e) {
      setState(() {
        _configError = e.toString();
      });
    }
  }

  // 分析安装策略
  void _analyzeInstallStrategy(AppLocalizations l10n) {
    if (_parsedConfig.isEmpty) return;
    
    // 🔧 检查配置是否有效
    if (!_parsedConfig.containsKey('mcpServers')) {
      print('🔧 配置分析失败: 缺少mcpServers字段');
      return;
    }
    
    final mcpServersData = _parsedConfig['mcpServers'];
    if (mcpServersData == null || mcpServersData is! Map<String, dynamic>) {
      print('🔧 配置分析失败: mcpServers字段格式错误');
      return;
    }
    
    final mcpServers = mcpServersData as Map<String, dynamic>;
    if (mcpServers.isEmpty) {
      print('🔧 配置分析失败: mcpServers为空');
      return;
    }
    
    final firstServerData = mcpServers.values.first;
    if (firstServerData == null || firstServerData is! Map<String, dynamic>) {
      print('🔧 配置分析失败: 服务器配置格式错误');
      return;
    }
    
    final firstServer = firstServerData as Map<String, dynamic>;
    
    // 🔧 解析并清理配置，处理特殊格式
    Map<String, dynamic> cleanedConfig;
    try {
      cleanedConfig = _cleanupServerConfig(firstServer);
    } catch (e) {
      print('🔧 配置清理失败: $e');
      cleanedConfig = firstServer; // 使用原始配置
    }
    final command = cleanedConfig['command'] as String;
    
    setState(() {
      if (command == 'uvx') {
        _detectedStrategy = InstallStrategy.uvx;
        _needsAdditionalInstall = false;
        _analysisResult = l10n.install_wizard_uvx_detected;
      } else if (command == 'npx') {
        _detectedStrategy = InstallStrategy.npx;
        _needsAdditionalInstall = false;
        _analysisResult = l10n.install_wizard_npx_detected;
      } else if (command == 'python' || command == 'python3') {
        _detectedStrategy = InstallStrategy.pip;
        _needsAdditionalInstall = true;
        _analysisResult = l10n.install_wizard_python_manual;
      } else if (command == 'node') {
        _detectedStrategy = InstallStrategy.npm;
        _needsAdditionalInstall = true;
        _analysisResult = l10n.install_wizard_nodejs_manual;
      } else {
        _detectedStrategy = InstallStrategy.local;
        _needsAdditionalInstall = true;
        _analysisResult = l10n.install_wizard_custom_manual;
      }
    });
    
    // 🚀 如果不需要额外安装配置，则自动切换页面
    if (!_needsAdditionalInstall) {
      _autoAdvanceSteps();
    }
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
    
    // 🔧 处理第二种格式：Windows cmd 命令
    if (command == 'cmd' && args.isNotEmpty) {
      // 提取 /c 后面的实际命令
      if (args[0] == '/c' && args.length > 1) {
        command = args[1]; // 提取实际命令（如 npx）
        args = args.sublist(2); // 移除 /c 和命令本身
        
        print('🔧 检测到Windows cmd格式，提取实际命令: $command');
        print('🔧 剩余参数: ${args.join(' ')}');
      }
    }
    
    // 🔧 处理第一种和第二种格式：带有 @smithery/cli 的特殊NPX格式
    if (command == 'npx' && args.isNotEmpty) {
      // 查找是否包含 @smithery/cli@latest 模式
      int smitheryIndex = -1;
      for (int i = 0; i < args.length; i++) {
        if (args[i].startsWith('@smithery/cli')) {
          smitheryIndex = i;
          break;
        }
      }
      
      if (smitheryIndex != -1) {
        print('🔧 检测到@smithery/cli格式，需要清理参数');
        print('🔧 原始参数: ${args.join(' ')}');
        
        // 移除 @smithery/cli@latest, run, --key, key值 这些参数
        final List<String> cleanedArgs = [];
        bool skipNext = false;
        
        for (int i = 0; i < args.length; i++) {
          if (skipNext) {
            skipNext = false;
            continue;
          }
          
          final arg = args[i];
          
          // 跳过 @smithery/cli@latest
          if (arg.startsWith('@smithery/cli')) {
            continue;
          }
          
          // 跳过 run 命令
          if (arg == 'run') {
            continue;
          }
          
          // 跳过 --key 及其对应的值
          if (arg == '--key') {
            skipNext = true; // 下一个参数是key的值，也要跳过
            continue;
          }
          
          // 保留其他参数
          cleanedArgs.add(arg);
        }
        
        args = cleanedArgs;
        print('🔧 清理后的参数: ${args.join(' ')}');
      }
    }
    
    // 🔧 处理UVX命令的类似情况（如果将来需要）
    if (command == 'uvx' && args.isNotEmpty) {
      // 查找是否包含类似的特殊模式
      int smitheryIndex = -1;
      for (int i = 0; i < args.length; i++) {
        if (args[i].startsWith('@smithery/cli')) {
          smitheryIndex = i;
          break;
        }
      }
      
      if (smitheryIndex != -1) {
        print('🔧 检测到UVX中的@smithery/cli格式，需要清理参数');
        print('🔧 原始参数: ${args.join(' ')}');
        
        // 同样的清理逻辑
        final List<String> cleanedArgs = [];
        bool skipNext = false;
        
        for (int i = 0; i < args.length; i++) {
          if (skipNext) {
            skipNext = false;
            continue;
          }
          
          final arg = args[i];
          
          // 跳过 @smithery/cli@latest
          if (arg.startsWith('@smithery/cli')) {
            continue;
          }
          
          // 跳过 run 命令
          if (arg == 'run') {
            continue;
          }
          
          // 跳过 --key 及其对应的值
          if (arg == '--key') {
            skipNext = true; // 下一个参数是key的值，也要跳过
            continue;
          }
          
          // 保留其他参数
          cleanedArgs.add(arg);
        }
        
        args = cleanedArgs;
        print('🔧 UVX清理后的参数: ${args.join(' ')}');
      }
    }
    
    // 更新清理后的配置
    cleanedConfig['command'] = command;
    cleanedConfig['args'] = args;
    
    return cleanedConfig;
  }

  // 解析命令并生成配置
  void _parseCommand() {
    final command = _commandController.text.trim();
    if (command.isEmpty) return;
    
    try {
      final config = _parseCommandToConfig(command);
      if (config != null) {
        setState(() {
          _configController.text = config;
        });
        _parseConfig();
        
        // 清空命令输入框
        _commandController.clear();
        
        // 显示成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('命令解析成功！配置已自动填入'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('命令解析失败：$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 将命令解析为MCP配置
  String? _parseCommandToConfig(String command) {
    final parts = _splitCommand(command);
    if (parts.isEmpty) return null;
    
    String cmd = parts[0];
    List<String> args = parts.sublist(1);
    
    // 处理不同的命令格式
    if (cmd == 'npx' || cmd == 'uvx') {
      // 清理参数，移除@smithery/cli相关内容
      final cleanedArgs = _cleanCommandArgs(cmd, args);
      
      // 提取服务器名称
      String serverName = _extractServerName(cleanedArgs);
      
      // 生成配置
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

  // 清理命令参数
  List<String> _cleanCommandArgs(String command, List<String> args) {
    final cleanedArgs = <String>[];
    bool skipNext = false;
    
    for (int i = 0; i < args.length; i++) {
      if (skipNext) {
        skipNext = false;
        continue;
      }
      
      final arg = args[i];
      
      // 跳过@smithery/cli相关内容
      if (arg.startsWith('@smithery/cli')) {
        continue;
      }
      
      // 跳过run命令
      if (arg == 'run') {
        continue;
      }
      
      // 跳过--key及其值
      if (arg == '--key') {
        skipNext = true;
        continue;
      }
      
      // 保留其他参数
      cleanedArgs.add(arg);
    }
    
    return cleanedArgs;
  }

  // 提取服务器名称
  String _extractServerName(List<String> args) {
    // 查找包名，通常是最后一个不以-开头的参数
    for (int i = args.length - 1; i >= 0; i--) {
      final arg = args[i];
      if (!arg.startsWith('-')) {
        // 提取包名的最后部分作为服务器名称
        if (arg.startsWith('@')) {
          // 处理@scope/package格式
          final parts = arg.split('/');
          if (parts.length >= 2) {
            return parts.last.replaceAll('-', '_');
          }
        } else {
          // 处理普通包名
          return arg.replaceAll('-', '_');
        }
      }
    }
    
    // 如果没有找到合适的名称，使用默认名称
    return 'mcp_server';
  }

  // 从@smithery/cli命令中提取服务器名称
  String _extractServerNameFromSmithery(List<String> args) {
    // 对于@smithery/cli run @scope/package格式，目标包通常在run后面
    for (int i = 0; i < args.length - 1; i++) {
      if (args[i] == 'run') {
        final targetPackage = args[i + 1];
        if (targetPackage.startsWith('@')) {
          // 提取包名的最后部分作为服务器名称
          final parts = targetPackage.split('/');
          if (parts.length >= 2) {
            return parts.last.replaceAll('-', '_');
          }
        } else {
          return targetPackage.replaceAll('-', '_');
        }
      }
    }
    
    // 如果没有找到合适的名称，使用默认名称
    return 'smithery_server';
  }

  // 分割命令，正确处理引号
  List<String> _splitCommand(String command) {
    final parts = <String>[];
    var current = '';
    var inQuotes = false;
    var quoteChar = '';
    
    for (int i = 0; i < command.length; i++) {
      final char = command[i];
      
      if (!inQuotes && (char == '"' || char == "'")) {
        inQuotes = true;
        quoteChar = char;
      } else if (inQuotes && char == quoteChar) {
        inQuotes = false;
        quoteChar = '';
      } else if (!inQuotes && char == ' ') {
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

  // 加载示例配置
  void _loadExampleConfig(String type) {
    String example = '';
    switch (type) {
      case 'uvx':
        example = '''
{
  "mcpServers": {
    "hotnews": {
      "command": "uvx",
      "args": ["mcp-server-hotnews"],
      "env": {
        "NEWS_API_KEY": "your-api-key"
      }
    }
  }
}''';
        break;
      case 'npx':
        example = '''
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/tmp"]
    }
  }
}''';
        break;
      case 'python':
        example = '''
{
  "mcpServers": {
    "custom-server": {
      "command": "python",
      "args": ["-m", "my_mcp_server"],
      "env": {
        "PYTHONPATH": "/path/to/server"
      }
    }
  }
}''';
        break;
    }
    
    setState(() {
      _configController.text = example;
    });
    _parseConfig();
  }

  String _getStrategyDisplayName(InstallStrategy strategy) {
    final l10n = AppLocalizations.of(context)!;
    switch (strategy) {
      case InstallStrategy.uvx:
        return l10n.install_wizard_strategy_uvx;
      case InstallStrategy.npx:
        return l10n.install_wizard_strategy_npx;
      case InstallStrategy.pip:
        return l10n.install_wizard_strategy_pip;
      case InstallStrategy.npm:
        return l10n.install_wizard_strategy_npm;
      case InstallStrategy.git:
        return l10n.install_wizard_strategy_git;
      case InstallStrategy.local:
        return l10n.install_wizard_strategy_local;
    }
  }

  // 按钮行为
  VoidCallback? _getNextButtonAction() {
    // 🔒 在自动切换过程中禁用按钮
    if (_isAutoAdvancing) {
      return null;
    }
    
    switch (_currentStep) {
      case 0:
        return _parsedConfig.isNotEmpty && _configError.isEmpty ? _analyzeConfigAndAdvance : null;
      case 1:
        return _nextStep;
      case 2:
        return _needsAdditionalInstall ? 
          (_validateInstallOptions() ? _nextStep : null) : _nextStep;
      case 3:
        return _installationSuccess ? _finishWizard : 
          (_isInstalling ? null : _startInstallation);
    }
    return null;
  }

  /// 分析配置并自动切换页面
  void _analyzeConfigAndAdvance() {
    // 先切换到分析页面
    _nextStep();
    
    // 触发分析（这会自动调用_autoAdvanceSteps）
    // 分析逻辑已经在_parseConfig中完成，这里只是确保触发自动切换
    if (!_needsAdditionalInstall) {
      _autoAdvanceSteps();
    }
  }

  String _getNextButtonText() {
    final l10n = AppLocalizations.of(context)!;
    switch (_currentStep) {
      case 0:
        return l10n.install_wizard_analyze_config;
      case 1:
        return l10n.common_next;
      case 2:
        return l10n.common_start_install;
      case 3:
        return _installationSuccess ? l10n.install_wizard_finish : 
          (_isInstalling ? l10n.common_installing : l10n.common_start_install);
    }
    return l10n.common_next;
  }

  bool _validateInstallOptions() {
    if (!_needsAdditionalInstall) return true;
    
    if (_selectedInstallType == 'github') {
      return _githubUrlController.text.isNotEmpty;
    } else if (_selectedInstallType == 'local') {
      return _localPathController.text.isNotEmpty;
    }
    return false;
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _saveState(); // 💾 保存状态
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 自动进行页面切换（当不需要用户额外输入时）
  Future<void> _autoAdvanceSteps() async {
    // 从步骤1（分析安装策略）开始自动切换
    if (_currentStep == 1 && !_needsAdditionalInstall) {
      setState(() {
        _isAutoAdvancing = true;
      });
      
      // 等待一小段时间让用户看到分析结果
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (mounted) {
        // 自动切换到步骤2（额外安装选项）
              setState(() {
        _currentStep = 2;
      });
      _saveState(); // 💾 保存状态
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
        
        // 再等待一小段时间
        await Future.delayed(const Duration(milliseconds: 800));
        
        if (mounted) {
          // 自动切换到步骤3（执行安装）
                  setState(() {
          _currentStep = 3;
        });
        _saveState(); // 💾 保存状态
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
          
          // 等待页面切换动画完成
          await Future.delayed(const Duration(milliseconds: 300));
          
          if (mounted) {
            setState(() {
              _isAutoAdvancing = false;
            });
          }
        }
      }
    }
  }

  void _previousStep() async {
    // 如果当前在安装步骤且正在安装中，需要确认取消
    if (_currentStep == 3 && _isInstalling) {
      // 检查是否有进程在运行（可能是恢复状态后）
      if (_currentInstallProcess != null || _currentInstallProcessPid != null) {
        final shouldCancel = await _showCancelInstallDialog();
        if (shouldCancel == true) {
          _cancelCurrentInstall();
          setState(() {
            _currentStep--;
          });
          _saveState(); // 💾 保存状态
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        return;
      } else {
        // 显示正在安装但没有进程引用，可能是进程已结束
        setState(() {
          _isInstalling = false;
          _installationLogs.add('⚠️ 检测到安装状态异常，已重置状态');
        });
        _saveState();
      }
    }
    
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _saveState(); // 💾 保存状态
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // 开始安装
  Future<void> _startInstallation() async {
    final l10n = AppLocalizations.of(context)!;
    
    setState(() {
      _isInstalling = true;
      _installationLogs.clear();
      _installationLogs.add('🚀 开始安装MCP服务器...');
    });
    _saveState(); // 💾 保存状态

    try {
      final mcpServerService = McpServerService.instance;
      final packageManager = PackageManagerService(
        runtimeManager: RuntimeManager.instance,
      );
      
      // 🔧 添加调试信息
      print('🔧 开始安装检查:');
      print('🔧 _parsedConfig是否为空: ${_parsedConfig.isEmpty}');
      print('🔧 _parsedConfig内容: $_parsedConfig');
      print('🔧 _configController.text: ${_configController.text}');
      
      // 🔧 检查配置是否有效，如果为空则重新解析
      if (_parsedConfig.isEmpty || !_parsedConfig.containsKey('mcpServers')) {
        print('🔧 _parsedConfig为空，尝试重新解析配置...');
        
        // 重新解析配置
        try {
          final config = json.decode(_configController.text);
          if (config is Map<String, dynamic> && config.containsKey('mcpServers')) {
            setState(() {
              _parsedConfig = config;
            });
            print('🔧 重新解析配置成功: $_parsedConfig');
          } else {
            throw Exception('配置格式无效');
          }
        } catch (e) {
          throw Exception('配置无效：无法解析JSON配置 - $e');
        }
      }
      
      // 再次检查配置是否有效
      if (_parsedConfig.isEmpty || !_parsedConfig.containsKey('mcpServers')) {
        throw Exception('配置无效：缺少mcpServers字段');
      }
      
      final mcpServersData = _parsedConfig['mcpServers'];
      if (mcpServersData == null || mcpServersData is! Map<String, dynamic>) {
        throw Exception('配置无效：mcpServers字段格式错误');
      }
      
      final mcpServers = mcpServersData as Map<String, dynamic>;
      if (mcpServers.isEmpty) {
        throw Exception('配置无效：mcpServers为空');
      }
      
      final serverName = mcpServers.keys.first;
      final originalServerConfigData = mcpServers[serverName];
      if (originalServerConfigData == null || originalServerConfigData is! Map<String, dynamic>) {
        throw Exception('配置无效：服务器配置格式错误');
      }
      
      final originalServerConfig = originalServerConfigData as Map<String, dynamic>;
      
      // 🔧 应用配置清理，处理特殊格式
      Map<String, dynamic> serverConfig;
      try {
        serverConfig = _cleanupServerConfig(originalServerConfig);
      } catch (e) {
        print('🔧 配置清理失败: $e');
        serverConfig = originalServerConfig; // 使用原始配置
      }
      
      setState(() {
        _installationLogs.add('📋 解析服务器配置: $serverName');
        _installationLogs.add('📋 原始命令: ${originalServerConfig['command']}');
        _installationLogs.add('📋 原始参数: ${originalServerConfig['args']}');
        if (serverConfig['command'] != originalServerConfig['command'] || 
            serverConfig['args'].toString() != originalServerConfig['args'].toString()) {
          _installationLogs.add('🔧 检测到特殊格式，已自动清理:');
          _installationLogs.add('📋 清理后命令: ${serverConfig['command']}');
          _installationLogs.add('📋 清理后参数: ${serverConfig['args']}');
        }
      });
      
      // 确定安装类型
      McpInstallType installType;
      InstallStrategy installStrategy;
      switch (_detectedStrategy) {
        case InstallStrategy.uvx:
          installType = McpInstallType.uvx;
          installStrategy = InstallStrategy.uvx;
          break;
        case InstallStrategy.npx:
          installType = McpInstallType.npx;
          installStrategy = InstallStrategy.npx;
          break;
        case InstallStrategy.pip:
          installType = McpInstallType.uvx;
          installStrategy = InstallStrategy.uvx;
          break;
        case InstallStrategy.npm:
          installType = McpInstallType.npx;
          installStrategy = InstallStrategy.npx;
          break;
        case InstallStrategy.git:
          installType = McpInstallType.github;
          installStrategy = InstallStrategy.git;
          break;
        case InstallStrategy.local:
          installType = McpInstallType.localPath;
          installStrategy = InstallStrategy.local;
          break;
        default:
          installType = McpInstallType.npx;
          installStrategy = InstallStrategy.npx;
      }
      
      setState(() {
        _installationLogs.add('🔧 安装类型: ${installType.name}');
      });
      
      // 获取包名作为安装源
      final args = (serverConfig['args'] as List?)?.cast<String>() ?? [];
      String? installSource;
      String packageName = '';
      
      if (args.isNotEmpty) {
        // 对于npx，去掉-y参数获取包名
        if (installType == McpInstallType.npx && args.contains('-y')) {
          final yIndex = args.indexOf('-y');
          if (yIndex + 1 < args.length) {
            packageName = args[yIndex + 1];
            installSource = packageName;
          }
        } else {
          packageName = args.first;
          installSource = packageName;
        }
      }
      
      setState(() {
        _installationLogs.add('📦 包名: $packageName');
        _installationLogs.add('🔄 开始实际安装过程...');
      });
      
      // 执行实际的安装
      InstallResult result;
      if (_needsAdditionalInstall) {
        // 需要额外安装步骤的情况（GitHub、本地等）
        if (_selectedInstallType == 'github') {
          final repoPackageName = _githubUrlController.text.split('/').last.replaceAll('.git', '');
          result = await packageManager.installPackage(
            packageName: repoPackageName,
            strategy: InstallStrategy.git,
            gitUrl: _githubUrlController.text,
            envVars: Map<String, String>.from(serverConfig['env'] ?? {}),
          );
        } else {
          final localPackageName = _localPathController.text.split('/').last;
          result = await packageManager.installPackage(
            packageName: localPackageName,
            strategy: InstallStrategy.local,
            localPath: _localPathController.text,
            envVars: Map<String, String>.from(serverConfig['env'] ?? {}),
          );
        }
      } else {
        // UVX/NPX自动安装（使用可取消版本）
        if (installStrategy == InstallStrategy.uvx) {
          // 对于UVX：安装时只需要包名，运行时参数在启动时使用
          result = await packageManager.installPackageCancellable(
            packageName: packageName,
            strategy: installStrategy,
            additionalArgs: null, // ❌ 不传递运行时参数给安装命令
            envVars: Map<String, String>.from(serverConfig['env'] ?? {}),
            onProcessStarted: (process) {
              setState(() {
                _currentInstallProcess = process;
                _currentInstallProcessPid = process.pid;
              });
              _saveState(); // 保存进程ID
            },
          );
        } else if (installStrategy == InstallStrategy.npx && args.contains('-y')) {
          // 对于NPX：移除-y参数，因为PackageManagerService会处理
          final filteredArgs = args.where((arg) => arg != '-y' && arg != packageName).toList();
          result = await packageManager.installPackageCancellable(
            packageName: packageName,
            strategy: installStrategy,
            additionalArgs: filteredArgs.isNotEmpty ? filteredArgs : null,
            envVars: Map<String, String>.from(serverConfig['env'] ?? {}),
            onProcessStarted: (process) {
              setState(() {
                _currentInstallProcess = process;
                _currentInstallProcessPid = process.pid;
              });
              _saveState(); // 保存进程ID
            },
          );
        } else {
          // 其他情况：传递额外参数
          final additionalArgs = args.length > 1 ? args.sublist(1) : null;
          result = await packageManager.installPackageCancellable(
            packageName: packageName,
            strategy: installStrategy,
            additionalArgs: additionalArgs,
            envVars: Map<String, String>.from(serverConfig['env'] ?? {}),
            onProcessStarted: (process) {
              setState(() {
                _currentInstallProcess = process;
                _currentInstallProcessPid = process.pid;
              });
              _saveState(); // 保存进程ID
            },
          );
        }
      }
      
      // 显示安装结果
      setState(() {
        if (result.output != null && result.output!.isNotEmpty) {
          _installationLogs.addAll(result.output!.split('\n').where((line) => line.isNotEmpty));
        }
        
        if (result.success) {
          _installationLogs.add('✅ 包安装成功！');
          _installationLogs.add('📦 正在添加服务器到MCP Hub...');
        } else {
          _installationLogs.add('❌ 包安装失败: ${result.errorMessage ?? '未知错误'}');
        }
      });
      
      if (result.success) {
        // 解析连接类型
        final configParser = McpConfigParser.instance;
        final connectionType = configParser.parseConnectionType(serverConfig);
        
        // 只有在包安装成功后才添加到服务器列表，并设置状态为已安装
        await mcpServerService.addServer(
          name: _nameController.text.isNotEmpty 
            ? _nameController.text 
            : serverName,
          description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : l10n.servers_description_hint,
          installType: installType,
          connectionType: connectionType,  // 使用解析的连接类型
          command: serverConfig['command'],
          args: args,
          env: Map<String, String>.from(serverConfig['env'] ?? {}),
          installSource: installSource,
          autoStart: false,
        );

        setState(() {
          _installationLogs.add('✅ 服务器已成功添加到MCP Hub');
          _installationLogs.add('🔄 更新服务器状态为已安装...');
        });

        // 获取刚添加的服务器并更新状态为已安装
        try {
          final allServers = await mcpServerService.getAllServers();
          final addedServer = allServers.firstWhere(
            (s) => s.name == (_nameController.text.isNotEmpty ? _nameController.text : serverName),
            orElse: () => throw Exception('无法找到刚添加的服务器'),
          );
          
          // 更新状态为已安装
          await mcpServerService.updateServerStatus(addedServer.id, McpServerStatus.installed);
          
                  setState(() {
          _installationLogs.add('✅ 服务器状态已更新为已安装');
          _installationLogs.add('🎯 安装完成，可以在服务器列表中启动该服务器');
          _installationSuccess = true;
          _isInstalling = false;
          _currentInstallProcess = null; // 清理进程引用
          _currentInstallProcessPid = null; // 清理进程ID
        });
        } catch (e) {
                  setState(() {
          _installationLogs.add('⚠️ 警告：无法更新服务器状态: $e');
          _installationLogs.add('✅ 但服务器已成功添加，可以手动启动');
          _installationSuccess = true;
          _isInstalling = false;
          _currentInstallProcess = null; // 清理进程引用
          _currentInstallProcessPid = null; // 清理进程ID
        });
        }
      } else {
        setState(() {
          _installationSuccess = false;
          _isInstalling = false;
          _currentInstallProcess = null; // 清理进程引用
          _currentInstallProcessPid = null; // 清理进程ID
        });
      }

    } catch (e) {
      setState(() {
        _installationLogs.add('❌ 安装失败: $e');
        _installationLogs.add('🔍 错误详情: ${e.toString()}');
        _isInstalling = false;
        _installationSuccess = false;
        _currentInstallProcess = null; // 清理进程引用
        _currentInstallProcessPid = null; // 清理进程ID
      });
    }
  }

  void _finishWizard() {
    // 🗑️ 清除保存的状态
    _persistentState.clear();
    print('🗑️ 安装完成，清除保存的状态');
    
    // 检查是否是从导航推送进来的（有返回按钮）
    if (Navigator.of(context).canPop()) {
      // 如果可以返回，就返回到上一个页面
      Navigator.of(context).pop(_installationSuccess);
    } else {
      // 如果不能返回，则跳转到主页
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  /// 显示取消安装确认对话框
  Future<bool?> _showCancelInstallDialog() async {
    final l10n = AppLocalizations.of(context)!;
    
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              Text(l10n.install_wizard_cancel_install_title),
            ],
          ),
          content: Text(l10n.install_wizard_cancel_install_message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.install_wizard_continue_install),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(l10n.install_wizard_cancel_install),
            ),
          ],
        );
      },
    );
  }

  /// 取消当前安装进程
  void _cancelCurrentInstall() {
    if (_currentInstallProcess != null) {
      _killProcessById(_currentInstallProcess!.pid);
    } else if (_currentInstallProcessPid != null) {
      // 如果没有进程引用但有PID，直接通过PID杀死进程
      _killProcessById(_currentInstallProcessPid!);
    }
  }

  /// 通过PID杀死进程
  void _killProcessById(int pid) {
    try {
      print('🔪 正在取消安装进程 $pid...');
      
      if (Platform.isWindows) {
        // Windows: 使用taskkill命令
        Process.run('taskkill', ['/F', '/PID', '$pid']);
      } else {
        // Unix系统: 使用kill命令
        Process.run('kill', ['-TERM', '$pid']).then((_) {
          // 如果进程仍在运行，3秒后强制杀死
          Future.delayed(const Duration(seconds: 3), () {
            Process.run('kill', ['-KILL', '$pid']).catchError((e) {
              // 进程可能已经结束，忽略错误
              return ProcessResult(0, 1, '', e.toString());
            });
          });
        });
      }
      
      setState(() {
        _installationLogs.add(AppLocalizations.of(context)!.install_wizard_installation_cancelled);
        _isInstalling = false;
        _installationSuccess = false;
        _currentInstallProcess = null;
        _currentInstallProcessPid = null;
      });
      
      print('✅ 安装进程已取消');
    } catch (e) {
      print('❌ 取消安装进程失败: $e');
      setState(() {
        _installationLogs.add('❌ 取消安装进程失败: $e');
      });
    }
  }

  /// 检查安装进程状态
  void _checkInstallProcessStatus(int pid) async {
    try {
      ProcessResult result;
      if (Platform.isWindows) {
        // Windows: 使用tasklist命令检查进程
        result = await Process.run('tasklist', ['/FI', 'PID eq $pid']);
      } else {
        // Unix系统: 使用ps命令检查进程
        result = await Process.run('ps', ['-p', '$pid']);
      }
      
      if (result.exitCode == 0 && result.stdout.toString().contains('$pid')) {
        // 进程仍在运行
        print('🔄 检测到安装进程 $pid 仍在运行');
        setState(() {
          _installationLogs.add('🔄 检测到之前的安装进程仍在运行...');
        });
      } else {
        // 进程已结束，清理状态
        print('⚠️ 安装进程 $pid 已结束，清理状态');
        setState(() {
          _isInstalling = false;
          _currentInstallProcessPid = null;
          _installationLogs.add('⚠️ 之前的安装进程已结束');
        });
        _saveState();
      }
    } catch (e) {
      print('❌ 检查进程状态失败: $e');
      // 检查失败，假设进程已结束
      setState(() {
        _isInstalling = false;
        _currentInstallProcessPid = null;
        _installationLogs.add('⚠️ 无法检查安装进程状态，假设已结束');
      });
      _saveState();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _configController.dispose();
    _githubUrlController.dispose();
    _localPathController.dispose();
    _installCommandController.dispose();
    super.dispose();
  }
} 