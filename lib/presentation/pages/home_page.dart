import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'servers_list_page.dart';
import 'hub_monitor_page.dart';
import 'settings_page.dart';
import 'installation_wizard_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard,
      label: '服务器管理',
      page: const ServersListPage(),
    ),
    NavigationItem(
      icon: Icons.add_circle,
      label: '安装服务器',
      page: const InstallationWizardPage(),
    ),
    NavigationItem(
      icon: Icons.monitor,
      label: '监控',
      page: const HubMonitorPage(),
    ),
    NavigationItem(
      icon: Icons.settings,
      label: '设置',
      page: const SettingsPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 侧边栏
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: _navigationItems
                .map((item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      label: Text(item.label),
                    ))
                .toList(),
            leading: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // 如果logo加载失败，显示默认图标
                        return Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.hub,
                            color: Colors.white,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'MCP Hub',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // 分割线
          const VerticalDivider(thickness: 1, width: 1),
          
          // 内容区域
          Expanded(
            child: _navigationItems[_selectedIndex].page,
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final Widget page;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.page,
  });
} 