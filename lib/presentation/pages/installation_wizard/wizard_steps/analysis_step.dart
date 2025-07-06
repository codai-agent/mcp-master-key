import 'package:flutter/material.dart';
import '../installation_wizard_controller.dart';

/// 分析步骤组件
class AnalysisStep extends StatelessWidget {
  final InstallationWizardController controller;

  const AnalysisStep({
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
            '分析安装策略',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '正在分析MCP服务器配置...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // 分析结果卡片
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: controller.state.detectedInstallType != null 
                ? Colors.green[50] 
                : Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: controller.state.detectedInstallType != null 
                  ? Colors.green[300]! 
                  : Colors.orange[300]!,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      controller.state.detectedInstallType != null 
                        ? Icons.check_circle 
                        : Icons.warning,
                      color: controller.state.detectedInstallType != null 
                        ? Colors.green 
                        : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '分析结果',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                if (controller.state.detectedInstallType != null) ...[
                  _buildAnalysisItem(
                    '安装类型',
                    _getInstallTypeDisplayName(controller.state.detectedInstallType!),
                    Icons.settings,
                  ),
                  const SizedBox(height: 8),
                  _buildAnalysisItem(
                    '安装方式',
                    controller.state.needsAdditionalInstall ? '需要手动配置' : '自动安装',
                    controller.state.needsAdditionalInstall ? Icons.settings : Icons.auto_mode,
                  ),
                  const SizedBox(height: 8),
                  _buildAnalysisItem(
                    '状态',
                    controller.state.analysisResult,
                    Icons.info,
                  ),
                ] else ...[
                  Text(
                    '正在分析配置...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 自动切换提示
          if (controller.state.isAutoAdvancing)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[300]!),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '正在自动切换到下一步...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
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
} 