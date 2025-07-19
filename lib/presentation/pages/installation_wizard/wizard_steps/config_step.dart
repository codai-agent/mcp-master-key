import 'package:flutter/material.dart';
import '../installation_wizard_controller.dart';
import '../../../widgets/json_config_editor.dart';
import '../../../../l10n/generated/app_localizations.dart';

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
    
    // 服务器名称现在由配置解析自动设置
    
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
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 页面标题
          Text(
            l10n.config_step_title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.config_step_subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // 主要内容区域 - 左右分栏
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧列 - 基本信息和快速配置
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 基本信息
                      _buildSectionHeader(l10n.config_step_basic_info),
                      const SizedBox(height: 12),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.label, color: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.config_step_server_name,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.controller.state.serverName.isEmpty
                                        ? l10n.config_step_server_name_hint
                                        : widget.controller.state.serverName,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: widget.controller.state.serverName.isEmpty
                                          ? Colors.grey[400]
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: l10n.config_step_server_description,
                          hintText: l10n.config_step_server_description_hint,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.description),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      
                      // 快速命令解析
                      _buildSectionHeader(l10n.config_step_quick_config),
                      const SizedBox(height: 12),
                      
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[300]!),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.flash_on, color: Colors.blue[700]),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        l10n.config_step_command_parse,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.config_step_command_parse_desc,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.blue[600],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                
                                TextField(
                                  controller: _commandController,
                                  decoration: InputDecoration(
                                    labelText: l10n.config_step_install_command,
                                    hintText: l10n.config_step_install_command_hint,
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.terminal),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.auto_fix_high),
                                      onPressed: _parseCommand,
                                      tooltip: l10n.config_step_parse_command_tooltip,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _parseCommand,
                                      icon: const Icon(Icons.auto_fix_high, size: 16),
                                      label: Text(l10n.config_step_parse_command),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[600],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _commandController.clear();
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      child: Text(l10n.config_step_clear),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 24),
                
                // 右侧列 - MCP配置和状态提示
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // MCP配置
                      _buildSectionHeader(l10n.config_step_mcp_config),
                      const SizedBox(height: 12),
                      
                      Expanded(
                        child: Container(
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
                      ),
                      const SizedBox(height: 16),
                      
                      // 配置状态提示
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
                              Expanded(
                                child: Text(
                                  l10n.config_step_config_parse_success,
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
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
    final l10n = AppLocalizations.of(context)!;
    final command = _commandController.text.trim();
    if (command.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.config_step_input_command_required),
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
        SnackBar(
          content: Text(l10n.config_step_command_parse_success),
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