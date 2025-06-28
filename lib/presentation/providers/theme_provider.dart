import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../business/services/config_service.dart';

/// 主题模式状态提供者
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// 主题状态管理器
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  /// 加载保存的主题模式
  Future<void> _loadThemeMode() async {
    try {
      final configService = ConfigService.instance;
      final themeMode = await configService.getThemeMode();
      state = _parseThemeMode(themeMode);
    } catch (e) {
      print('加载主题模式失败: $e');
      // 如果加载失败，使用系统默认
      state = ThemeMode.system;
    }
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final configService = ConfigService.instance;
      await configService.setThemeMode(_themeModeToString(mode));
      state = mode;
    } catch (e) {
      print('保存主题模式失败: $e');
    }
  }

  /// 切换深色模式
  Future<void> toggleDarkMode(bool isDark) async {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// 是否为深色模式
  bool get isDarkMode => state == ThemeMode.dark;

  /// 是否为浅色模式
  bool get isLightMode => state == ThemeMode.light;

  /// 是否跟随系统
  bool get isSystemMode => state == ThemeMode.system;

  /// 解析主题模式字符串
  ThemeMode _parseThemeMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// 主题模式转字符串
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }
} 