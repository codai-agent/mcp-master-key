import 'package:flutter/material.dart';
import '../installation_wizard_controller.dart';
import '../../../widgets/json_config_editor.dart';

/// 配置步骤组件
class ConfigStep extends StatefulWidget {
  final InstallationWizardController controller;

  const ConfigStep({
    super.key,
    required this.controller,
  });

  @override
  State<ConfigStep> createState() => _ConfigStepState();
}

class _ConfigStepState extends State<ConfigStep> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _configController = TextEditingController();
  final TextEditingController _commandController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // 初始化控制器
    _nameController.text = widget.controller.state.serverName;
    _descriptionController.text = widget.controller.state.serverDescription;
    _configController.text = widget.controller.state.configText;
    
    // 监听控制器变化
    _nameController.addListener(() {
      widget.controller.updateServerName(_nameController.text);
    });
    
    _descriptionController.addListener(() {
      widget.controller.updateServerDescription(_descriptionController.text);
    });
    
    _configController.addListener(() {
      widget.controller.updateConfigText(_configController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _configController.dispose();
    _commandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            '请输入MCP服务器的基本信息和配置',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 基本信息
                  _buildSectionHeader('基本信息'),
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '服务器名称（可选）',
                      hintText: '例如：my-mcp-server',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '服务器描述（可选）',
                      hintText: '例如：用于文件操作的MCP服务器',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  
                  // 快速命令解析
                  _buildSectionHeader('快速配置'),
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.flash_on, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              '命令解析',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '如果您有现成的安装命令，可以直接粘贴到这里自动生成配置',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        TextField(
                          controller: _commandController,
                          decoration: InputDecoration(
                            labelText: '安装命令',
                            hintText: '例如：npx -y @modelcontextprotocol/server-filesystem',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.terminal),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.auto_fix_high),
                              onPressed: _parseCommand,
                              tooltip: '解析命令',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _parseCommand,
                              icon: const Icon(Icons.auto_fix_high, size: 16),
                              label: const Text('解析命令'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                _commandController.clear();
                              },
                              child: const Text('清空'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // MCP配置
                  _buildSectionHeader('MCP配置'),
                  const SizedBox(height: 12),
                  
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: JsonConfigEditor(
                      initialValue: widget.controller.state.configText,
                      onChanged: (value) {
                        widget.controller.updateConfigText(value);
                        widget.controller.parseConfig();
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 配置错误提示
                  if (widget.controller.state.configError.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[300]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.controller.state.configError,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // 配置成功提示
                  if (widget.controller.state.configError.isEmpty && 
                      widget.controller.state.parsedConfig.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[300]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              '配置解析成功！',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _parseCommand() {
    final command = _commandController.text.trim();
    if (command.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入安装命令'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      widget.controller.parseCommand(command);
      
      // 更新UI中的配置文本
      _configController.text = widget.controller.state.configText;
      
      // 清空命令输入框
      _commandController.clear();
      
      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('命令解析成功！配置已自动填入'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('命令解析失败：$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 