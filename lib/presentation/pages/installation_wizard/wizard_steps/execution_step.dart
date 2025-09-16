import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../installation_wizard_controller.dart';

/// 执行步骤组件
class ExecutionStep extends StatefulWidget {
  final InstallationWizardController controller;

  const ExecutionStep({
    super.key,
    required this.controller,
  });

  @override
  State<ExecutionStep> createState() => _ExecutionStepState();
}

class _ExecutionStepState extends State<ExecutionStep> {
  late final ScrollController _logScrollController;

  @override
  void initState() {
    super.initState();
    _logScrollController = ScrollController();
  }

  @override
  void dispose() {
    _logScrollController.dispose();
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
          Text(
            l10n.execution_step_title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            widget.controller.state.installationSuccess 
              ? l10n.execution_step_subtitle_completed
              : (widget.controller.state.isInstalling ? l10n.execution_step_subtitle_installing : l10n.execution_step_subtitle_ready),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: widget.controller.state.installationSuccess 
                ? Colors.green[600]
                : (widget.controller.state.isInstalling ? Colors.blue[600] : Colors.grey[600]),
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
                      l10n.execution_step_summary,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSummaryItem(
                  l10n.execution_step_server_name, 
                  widget.controller.state.serverName.isNotEmpty 
                    ? widget.controller.state.serverName 
                    : l10n.execution_step_unnamed
                ),
                if (widget.controller.state.serverDescription.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildSummaryItem(l10n.execution_step_description, widget.controller.state.serverDescription),
                ],
                if (widget.controller.state.detectedInstallType != null) ...[
                  const SizedBox(height: 8),
                  _buildSummaryItem(
                    l10n.execution_step_install_type, 
                    _getInstallTypeDisplayName(widget.controller.state.detectedInstallType!, l10n)
                  ),
                ],
                if (widget.controller.state.needsAdditionalInstall) ...[
                  const SizedBox(height: 8),
                  _buildSummaryItem(
                    l10n.execution_step_install_source, 
                    widget.controller.state.selectedInstallType == 'github' 
                      ? l10n.execution_step_github_repo
                      : l10n.execution_step_local_path
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 安装日志
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Scrollbar(
                controller: _logScrollController,
                thumbVisibility: true,
                trackVisibility: true,
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                            l10n.execution_step_install_logs,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (widget.controller.state.isInstalling)
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
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            scrollbars: false,
                          ),
                          child: SingleChildScrollView(
                            controller: _logScrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.controller.state.installationLogs.isEmpty)
                                  Text(
                                    l10n.execution_step_waiting_install,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[400],
                                      fontFamily: 'monospace',
                                    ),
                                  )
                                else
                                  ...widget.controller.state.installationLogs.map(
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // 底部操作按钮
          if (widget.controller.state.isInstalling) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancelDialog(context),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: Text(l10n.execution_step_cancel_install),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (widget.controller.state.installationSuccess) ...[
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
                          l10n.execution_step_install_completed,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.execution_step_server_list_hint,
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
      case 'McpInstallType.localNode':
        return l10n.analysis_step_install_type_local_node;
      default:
        return l10n.analysis_step_install_type_unknown;
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
    final shouldCancel = await widget.controller.showCancelInstallDialog(context);
    if (shouldCancel == true) {
      widget.controller.cancelInstallation();
    }
  }
} 