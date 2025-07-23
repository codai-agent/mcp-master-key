import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'servers_list_page.dart';
import 'hub_monitor_page.dart';
import 'settings_page.dart';
import 'installation_wizard_page_new.dart';
import 'mcp_market_page.dart';
import '../themes/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 1;
  bool _isSidebarExpanded = true;
  
  List<NavigationItem> _getNavigationItems(AppLocalizations l10n) {
    return [
      NavigationItem(
        icon: Icons.store,
        label: l10n.nav_market,
        page: const McpMarketPage(),
      ),
      NavigationItem(
        icon: Icons.dashboard,
        label: l10n.nav_servers,
        page: const ServersListPage(),
      ),
      NavigationItem(
        icon: Icons.add_circle,
        label: l10n.nav_install,
        page: const InstallationWizardPageNew(),
      ),
      NavigationItem(
        icon: Icons.monitor,
        label: l10n.nav_monitor,
        page: const HubMonitorPage(),
      ),
      NavigationItem(
        icon: Icons.settings,
        label: l10n.nav_settings,
        page: const SettingsPage(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final navigationItems = _getNavigationItems(l10n);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sidebarColor = isDark ? AppTheme.darkSidebar : AppTheme.lightSidebar;
    
    return Scaffold(
      body: Row(
        children: [
          // VS Code风格侧边栏
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isSidebarExpanded ? 280 : 60,
            color: sidebarColor,
            child: Column(
              children: [
                // 顶部Logo区域
                Container(
                  padding: const EdgeInsets.all(16),
                  child: _isSidebarExpanded 
                    ? Row(
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
                                  l10n.appTitle,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                                  ),
                                ),
                                Text(
                                  l10n.appSubtitle,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppTheme.vscodeBlue,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.hub,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
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
                    itemCount: navigationItems.length,
                    itemBuilder: (context, index) {
                      final item = navigationItems[index];
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
                        child: _isSidebarExpanded
                          ? ListTile(
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
                            )
                          : Tooltip(
                              message: item.label,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = index;
                                  });
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  height: 44,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    item.icon,
                                    size: 20,
                                    color: isSelected 
                                      ? AppTheme.vscodeBlue
                                      : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                                  ),
                                ),
                              ),
                            ),
                      );
                    },
                  ),
                ),
                
                // 折叠/展开按钮
                Container(
                  margin: const EdgeInsets.all(8),
                  child: Tooltip(
                    message: _isSidebarExpanded ? l10n.sidebar_collapse : l10n.sidebar_expand,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isSidebarExpanded = !_isSidebarExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: isDark 
                            ? Colors.white.withOpacity(0.05) 
                            : Colors.black.withOpacity(0.05),
                        ),
                        child: Row(
                          mainAxisAlignment: _isSidebarExpanded 
                            ? MainAxisAlignment.end 
                            : MainAxisAlignment.center,
                          children: [
                            if (_isSidebarExpanded) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.sidebar_collapse,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                  ),
                                ),
                              ),
                            ],
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: _isSidebarExpanded ? 8 : 0,
                              ),
                              child: Icon(
                                _isSidebarExpanded 
                                  ? Icons.keyboard_arrow_left 
                                  : Icons.keyboard_arrow_right,
                                size: 16,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
            child: navigationItems[_selectedIndex].page,
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