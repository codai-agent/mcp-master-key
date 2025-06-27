import 'package:flutter/material.dart';
import 'dart:convert';
import '../../business/services/package_manager_service.dart';
import '../../business/services/mcp_server_service.dart';
import '../../core/models/mcp_server.dart';
import '../../infrastructure/runtime/runtime_manager.dart';
import '../widgets/json_config_editor.dart';

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
    // 预填充示例配置
    _configController.text = '''
{
  "mcpServers": {
    "example-server": {
      "command": "uvx",
      "args": ["mcp-server-hotnews"],
      "env": {
        "API_KEY": "your-api-key"
      }
    }
  }
}''';
    _parseConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCP服务器安装向导'),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          // 步骤指示器
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStepIndicator(0, '配置服务器', '必填'),
                _buildStepConnector(),
                _buildStepIndicator(1, '分析安装', '自动'),
                _buildStepConnector(),
                _buildStepIndicator(2, '安装选项', '可选'),
                _buildStepConnector(),
                _buildStepIndicator(3, '执行安装', '完成'),
              ],
            ),
          ),
          
          // 页面内容
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildConfigStep(),
                _buildAnalysisStep(),
                _buildInstallOptionsStep(),
                _buildExecutionStep(),
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
                      child: const Text('上一步'),
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
  Widget _buildConfigStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '配置MCP服务器',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '请填写MCP服务器的基本信息和配置。mcpServers配置是必填项，用于确定启动命令和安装方式。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // 服务器名称
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '服务器名称',
              hintText: '例如：热点新闻服务器',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          // 服务器描述
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: '服务器描述（可选）',
              hintText: '简单描述这个MCP服务器的功能',
              border: OutlineInputBorder(),
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
          ),
          
          // 配置帮助
          Container(
            margin: const EdgeInsets.only(top: 8),
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
                    Icon(Icons.info, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      '配置说明',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('• 如果使用 uvx/npx 命令，系统会自动安装包'),
                const Text('• 如果使用其他命令，可能需要额外的安装步骤'),
                const Text('• 支持环境变量配置和命令行参数'),
              ],
            ),
          ),
          
          // 配置示例按钮
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _loadExampleConfig('uvx'),
                icon: const Icon(Icons.code, size: 16),
                label: const Text('UVX示例'),
              ),
              ElevatedButton.icon(
                onPressed: () => _loadExampleConfig('npx'),
                icon: const Icon(Icons.code, size: 16),
                label: const Text('NPX示例'),
              ),
              ElevatedButton.icon(
                onPressed: () => _loadExampleConfig('python'),
                icon: const Icon(Icons.code, size: 16),
                label: const Text('Python示例'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 第二步：分析安装策略
  Widget _buildAnalysisStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '安装策略分析',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '系统正在分析您的配置，确定最佳的安装策略。',
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
                        '检测到安装策略: ${_getStrategyDisplayName(_detectedStrategy!)}',
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
                          '需要额外的安装步骤',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('由于您的配置不使用uvx/npx，需要手动配置安装源。'),
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
                          '自动安装就绪',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('系统将自动下载和安装所需的包，无需额外配置。'),
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
  Widget _buildInstallOptionsStep() {
    if (!_needsAdditionalInstall) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.skip_next, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                '无需额外配置',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('您的配置支持自动安装，可以直接进行下一步。'),
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
            '配置安装源',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '由于您的配置不使用uvx/npx，请选择安装源类型并提供相关信息。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // 安装类型选择
          Text(
            '安装源类型',
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
                  title: const Text('GitHub源码'),
                  subtitle: const Text('从GitHub仓库克隆并安装'),
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
                  title: const Text('本地路径'),
                  subtitle: const Text('从本地文件系统安装'),
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
              decoration: const InputDecoration(
                labelText: 'GitHub仓库地址',
                hintText: 'https://github.com/owner/repo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
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
                        '自动分析',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('系统将自动分析仓库结构并确定最佳安装命令。'),
                ],
              ),
            ),
          ] else if (_selectedInstallType == 'local') ...[
            TextField(
              controller: _localPathController,
              decoration: InputDecoration(
                labelText: '本地路径',
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
            decoration: const InputDecoration(
              labelText: '安装命令（可选）',
              hintText: '例如：pip install -e . 或 npm install',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.terminal),
            ),
          ),
        ],
      ),
    );
  }

  // 第四步：执行安装
  Widget _buildExecutionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '安装执行',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _isInstalling 
              ? '正在安装MCP服务器，请稍候...' 
              : _installationSuccess
                ? '安装完成！MCP服务器已成功添加到您的服务器列表。'
                : '准备开始安装，点击"开始安装"按钮。',
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
                  '安装摘要',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildSummaryItem('服务器名称', _nameController.text.isNotEmpty ? _nameController.text : '未命名'),
                if (_descriptionController.text.isNotEmpty)
                  _buildSummaryItem('描述', _descriptionController.text),
                if (_detectedStrategy != null)
                  _buildSummaryItem('安装策略', _getStrategyDisplayName(_detectedStrategy!)),
                if (_needsAdditionalInstall)
                  _buildSummaryItem('安装源', _selectedInstallType == 'github' ? 'GitHub源码' : '本地路径'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 安装日志
          if (_installationLogs.isNotEmpty) ...[
            Text(
              '安装日志',
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
                          '安装成功！',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                            fontSize: 14, // 减少字体大小
                          ),
                        ),
                        Text(
                          'MCP服务器已添加到您的服务器列表，可以开始使用了。',
                          style: TextStyle(fontSize: 12), // 减少字体大小
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
      _analyzeInstallStrategy();
      
    } catch (e) {
      setState(() {
        _configError = e.toString();
      });
    }
  }

  // 分析安装策略
  void _analyzeInstallStrategy() {
    if (_parsedConfig.isEmpty) return;
    
    final mcpServers = _parsedConfig['mcpServers'] as Map<String, dynamic>;
    final firstServer = mcpServers.values.first as Map<String, dynamic>;
    final command = firstServer['command'] as String;
    
    setState(() {
      if (command == 'uvx') {
        _detectedStrategy = InstallStrategy.uvx;
        _needsAdditionalInstall = false;
        _analysisResult = '检测到UVX命令，系统将自动使用uv工具安装Python包。';
      } else if (command == 'npx') {
        _detectedStrategy = InstallStrategy.npx;
        _needsAdditionalInstall = false;
        _analysisResult = '检测到NPX命令，系统将自动使用npm安装Node.js包。';
      } else if (command == 'python' || command == 'python3') {
        _detectedStrategy = InstallStrategy.pip;
        _needsAdditionalInstall = true;
        _analysisResult = '检测到Python命令，需要配置包的安装源（GitHub或本地路径）。';
      } else if (command == 'node') {
        _detectedStrategy = InstallStrategy.npm;
        _needsAdditionalInstall = true;
        _analysisResult = '检测到Node.js命令，需要配置包的安装源（GitHub或本地路径）。';
      } else {
        _detectedStrategy = InstallStrategy.local;
        _needsAdditionalInstall = true;
        _analysisResult = '检测到自定义命令，需要手动配置安装源和方式。';
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
    switch (strategy) {
      case InstallStrategy.uvx:
        return 'UVX (Python包管理)';
      case InstallStrategy.npx:
        return 'NPX (Node.js包管理)';
      case InstallStrategy.pip:
        return 'PIP (Python安装)';
      case InstallStrategy.npm:
        return 'NPM (Node.js安装)';
      case InstallStrategy.git:
        return 'Git克隆';
      case InstallStrategy.local:
        return '本地安装';
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
    switch (_currentStep) {
      case 0:
        return '分析配置';
      case 1:
        return '下一步';
      case 2:
        return '开始安装';
      case 3:
        return _installationSuccess ? '完成' : 
          (_isInstalling ? '安装中...' : '开始安装');
    }
    return '下一步';
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
        // 只有在包安装成功后才添加到服务器列表，并设置状态为已安装
        await mcpServerService.addServer(
          name: _nameController.text.isNotEmpty 
            ? _nameController.text 
            : serverName,
          description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : '通过安装向导添加的MCP服务器',
          installType: installType,
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
    // 返回true表示安装成功，需要刷新服务器列表
    Navigator.of(context).pop(_installationSuccess);
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