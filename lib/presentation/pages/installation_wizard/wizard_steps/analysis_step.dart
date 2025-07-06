import 'package:flutter/material.dart';
import '../installation_wizard_controller.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// 分析步骤组件
class AnalysisStep extends StatelessWidget {
  final InstallationWizardController controller;

  const AnalysisStep({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.analysis_step_title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.analysis_step_subtitle,
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
                      l10n.analysis_step_result,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                if (controller.state.detectedInstallType != null) ...[
                  _buildAnalysisItem(
                    l10n.analysis_step_install_type,
                    _getInstallTypeDisplayName(controller.state.detectedInstallType!, l10n),
                    Icons.settings,
                  ),
                  const SizedBox(height: 8),
                  _buildAnalysisItem(
                    l10n.analysis_step_install_method,
                    controller.state.needsAdditionalInstall ? l10n.analysis_step_manual_config : l10n.analysis_step_auto_install,
                    controller.state.needsAdditionalInstall ? Icons.settings : Icons.auto_mode,
                  ),
                  const SizedBox(height: 8),
                  _buildAnalysisItem(
                    l10n.analysis_step_status,
                    controller.state.analysisResult,
                    Icons.info,
                  ),
                ] else ...[
                  Text(
                    l10n.analysis_step_analyzing,
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
                    l10n.analysis_step_auto_advancing,
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

  String _getInstallTypeDisplayName(dynamic installType, AppLocalizations l10n) {
    switch (installType.toString()) {
      case 'McpInstallType.uvx':
        return l10n.analysis_step_install_type_uvx;
      case 'McpInstallType.npx':
        return l10n.analysis_step_install_type_npx;
      case 'McpInstallType.smithery':
        return l10n.analysis_step_install_type_smithery;
      case 'McpInstallType.localPython':
        return l10n.analysis_step_install_type_local_python;
      case 'McpInstallType.localJar':
        return l10n.analysis_step_install_type_local_jar;
      case 'McpInstallType.localExecutable':
        return l10n.analysis_step_install_type_local_executable;
      default:
        return l10n.analysis_step_install_type_unknown;
    }
  }
} 