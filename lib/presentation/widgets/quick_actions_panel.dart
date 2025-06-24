import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/installation_wizard_page.dart';
import '../pages/config_import_page.dart';

/// 快速动作面板
class QuickActionsPanel extends ConsumerWidget {
  const QuickActionsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '快速操作',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.download,
                  label: '安装向导',
                  subtitle: '快速安装MCP服务器',
                  color: Colors.blue,
                  onTap: () => _navigateToInstallWizard(context),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.add_circle_outline,
                  label: '添加服务器',
                  subtitle: '手动配置服务器',
                  color: Colors.green,
                  onTap: () => _navigateToConfigImport(context),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.refresh,
                  label: '刷新列表',
                  subtitle: '重新加载服务器',
                  color: Colors.orange,
                  onTap: () => _refreshServerList(ref),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.settings,
                  label: '应用设置',
                  subtitle: '调整应用配置',
                  color: Colors.purple,
                  onTap: () => _navigateToSettings(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToInstallWizard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InstallationWizardPage(),
      ),
    );
  }

  void _navigateToConfigImport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ConfigImportPage(),
      ),
    );
  }

  void _refreshServerList(WidgetRef ref) {
    // TODO: 实现刷新服务器列表逻辑
    // ref.refresh(serversListProvider);
  }

  void _navigateToSettings(BuildContext context) {
    // 由于设置页面已经在主导航中，这里可以显示提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('请点击左侧导航栏的"设置"选项'),
        duration: Duration(seconds: 2),
      ),
    );
  }
} 