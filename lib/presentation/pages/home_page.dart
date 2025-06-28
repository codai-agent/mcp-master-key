import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'servers_list_page.dart';
import 'hub_monitor_page.dart';
import 'settings_page.dart';
import 'installation_wizard_page.dart';
import '../themes/app_theme.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sidebarColor = isDark ? AppTheme.darkSidebar : AppTheme.lightSidebar;
    
    return Scaffold(
      body: Row(
        children: [
          // VS Code风格侧边栏
          Container(
            width: 280,
            color: sidebarColor,
            child: Column(
              children: [
                // 顶部Logo区域
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppTheme.vscodeBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.hub,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MCP Hub',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppTheme.darkText : AppTheme.lightText,
                              ),
                            ),
                            Text(
                              'Model Context Protocol',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 分割线
                Divider(
                  height: 1,
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
                
                // 导航菜单
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _navigationItems.length,
                    itemBuilder: (context, index) {
                      final item = _navigationItems[index];
                      final isSelected = index == _selectedIndex;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? AppTheme.vscodeBlue.withOpacity(0.1)
                            : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: isSelected 
                            ? Border.all(color: AppTheme.vscodeBlue.withOpacity(0.3))
                            : null,
                        ),
                        child: ListTile(
                          dense: true,
                          leading: Icon(
                            item.icon,
                            size: 20,
                            color: isSelected 
                              ? AppTheme.vscodeBlue
                              : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                          ),
                          title: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                              color: isSelected 
                                ? AppTheme.vscodeBlue
                                : (isDark ? AppTheme.darkText : AppTheme.lightText),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // 分割线
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
          
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