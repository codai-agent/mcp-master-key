import 'package:flutter/material.dart';
import '../installation_wizard_controller.dart';

/// 执行步骤组件
class ExecutionStep extends StatelessWidget {
  final InstallationWizardController controller;

  const ExecutionStep({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '执行安装',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            controller.state.installationSuccess 
              ? '安装已完成！' 
              : (controller.state.isInstalling ? '正在安装MCP服务器...' : '准备安装MCP服务器'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: controller.state.installationSuccess 
                ? Colors.green[600]
                : (controller.state.isInstalling ? Colors.blue[600] : Colors.grey[600]),
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
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '安装摘要',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSummaryItem(
                  '服务器名称', 
                  controller.state.serverName.isNotEmpty 
                    ? controller.state.serverName 
                    : '未命名'
                ),
                if (controller.state.serverDescription.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildSummaryItem('描述', controller.state.serverDescription),
                ],
                if (controller.state.detectedInstallType != null) ...[
                  const SizedBox(height: 8),
                  _buildSummaryItem(
                    '安装类型', 
                    _getInstallTypeDisplayName(controller.state.detectedInstallType!)
                  ),
                ],
                if (controller.state.needsAdditionalInstall) ...[
                  const SizedBox(height: 8),
                  _buildSummaryItem(
                    '安装源', 
                    controller.state.selectedInstallType == 'github' 
                      ? 'GitHub仓库' 
                      : '本地路径'
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 安装日志
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.terminal,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '安装日志',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (controller.state.isInstalling)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (controller.state.installationLogs.isEmpty)
                            Text(
                              '等待开始安装...',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[400],
                                fontFamily: 'monospace',
                              ),
                            )
                          else
                            ...controller.state.installationLogs.map(
                              (log) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  log,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _getLogColor(log),
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 底部操作按钮
          if (controller.state.isInstalling) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancelDialog(context),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text('取消安装'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (controller.state.installationSuccess) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '安装完成！',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '您可以在服务器列表中启动该服务器',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  String _getInstallTypeDisplayName(dynamic installType) {
    switch (installType.toString()) {
      case 'McpInstallType.uvx':
        return 'UVX (Python包管理器)';
      case 'McpInstallType.npx':
        return 'NPX (Node.js包管理器)';
      case 'McpInstallType.smithery':
        return 'Smithery (MCP包管理器)';
      case 'McpInstallType.localPython':
        return '本地Python包';
      case 'McpInstallType.localJar':
        return '本地JAR包';
      case 'McpInstallType.localExecutable':
        return '本地可执行文件';
      default:
        return '未知类型';
    }
  }

  Color _getLogColor(String log) {
    if (log.startsWith('✅') || log.startsWith('🎉') || log.startsWith('🎯')) {
      return Colors.green[300]!;
    } else if (log.startsWith('❌')) {
      return Colors.red[300]!;
    } else if (log.startsWith('⚠️')) {
      return Colors.orange[300]!;
    } else if (log.startsWith('🔧') || log.startsWith('📋')) {
      return Colors.blue[300]!;
    } else if (log.startsWith('🚀') || log.startsWith('🔄')) {
      return Colors.cyan[300]!;
    } else if (log.startsWith('📦')) {
      return Colors.purple[300]!;
    } else if (log.startsWith('🚫')) {
      return Colors.red[400]!;
    } else {
      return Colors.grey[300]!;
    }
  }

  void _showCancelDialog(BuildContext context) async {
    final shouldCancel = await controller.showCancelInstallDialog(context);
    if (shouldCancel == true) {
      controller.cancelInstallation();
    }
  }
} 