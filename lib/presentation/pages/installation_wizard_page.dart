import 'package:flutter/material.dart';
import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    // 初始化为空配置，显示占位符
    _configController.text = '''
{
  "mcpServers": {
  }
}''';
    _parseConfig();
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
                      onPressed: _previousStep,
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
              hintText: '例如：热点新闻服务器',
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
              hintText: '简单描述这个MCP服务器的功能',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          // MCP配置
          Text(
            'MCP服务器配置 *',
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
            placeholderText: l10n.install_wizard_config_placeholder,
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

  // 第四步：执行安装
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
    
    final mcpServers = _parsedConfig['mcpServers'] as Map<String, dynamic>;
    final firstServer = mcpServers.values.first as Map<String, dynamic>;
    final command = firstServer['command'] as String;
    
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
    switch (_currentStep) {
      case 0:
        return _parsedConfig.isNotEmpty && _configError.isEmpty ? _nextStep : null;
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
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
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

    try {
      final mcpServerService = McpServerService.instance;
      final packageManager = PackageManagerService(
        runtimeManager: RuntimeManager.instance,
      );
      
      final mcpServers = _parsedConfig['mcpServers'] as Map<String, dynamic>;
      final serverName = mcpServers.keys.first;
      final serverConfig = mcpServers[serverName] as Map<String, dynamic>;
      
      setState(() {
        _installationLogs.add('📋 解析服务器配置: $serverName');
        _installationLogs.add('📋 命令: ${serverConfig['command']}');
        _installationLogs.add('📋 参数: ${serverConfig['args']}');
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
        // UVX/NPX自动安装
        if (installStrategy == InstallStrategy.uvx) {
          // 对于UVX：安装时只需要包名，运行时参数在启动时使用
          result = await packageManager.installPackage(
            packageName: packageName,
            strategy: installStrategy,
            additionalArgs: null, // ❌ 不传递运行时参数给安装命令
            envVars: Map<String, String>.from(serverConfig['env'] ?? {}),
          );
        } else if (installStrategy == InstallStrategy.npx && args.contains('-y')) {
          // 对于NPX：移除-y参数，因为PackageManagerService会处理
          final filteredArgs = args.where((arg) => arg != '-y' && arg != packageName).toList();
          result = await packageManager.installPackage(
            packageName: packageName,
            strategy: installStrategy,
            additionalArgs: filteredArgs.isNotEmpty ? filteredArgs : null,
            envVars: Map<String, String>.from(serverConfig['env'] ?? {}),
          );
        } else {
          // 其他情况：传递额外参数
          final additionalArgs = args.length > 1 ? args.sublist(1) : null;
          result = await packageManager.installPackage(
            packageName: packageName,
            strategy: installStrategy,
            additionalArgs: additionalArgs,
            envVars: Map<String, String>.from(serverConfig['env'] ?? {}),
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
          });
        } catch (e) {
          setState(() {
            _installationLogs.add('⚠️ 警告：无法更新服务器状态: $e');
            _installationLogs.add('✅ 但服务器已成功添加，可以手动启动');
            _installationSuccess = true;
            _isInstalling = false;
          });
        }
      } else {
        setState(() {
          _installationSuccess = false;
          _isInstalling = false;
        });
      }

    } catch (e) {
      setState(() {
        _installationLogs.add('❌ 安装失败: $e');
        _installationLogs.add('🔍 错误详情: ${e.toString()}');
        _isInstalling = false;
        _installationSuccess = false;
      });
    }
  }

  void _finishWizard() {
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