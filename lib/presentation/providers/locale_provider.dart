import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../business/services/config_service.dart';

/// 支持的语言枚举
enum AppLanguage {
  system,
  english,
  chinese,
}

extension AppLanguageExtension on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.system:
        return 'system';
      case AppLanguage.english:
        return 'en';
      case AppLanguage.chinese:
        return 'zh';
    }
  }

  String get name {
    switch (this) {
      case AppLanguage.system:
        return 'System Default';
      case AppLanguage.english:
        return 'English';
      case AppLanguage.chinese:
        return '中文';
    }
  }

  Locale? get locale {
    switch (this) {
      case AppLanguage.system:
        return null; // 使用系统默认
      case AppLanguage.english:
        return const Locale('en');
      case AppLanguage.chinese:
        return const Locale('zh');
    }
  }

  static AppLanguage fromCode(String code) {
    switch (code) {
      case 'system':
        return AppLanguage.system;
      case 'en':
        return AppLanguage.english;
      case 'zh':
        return AppLanguage.chinese;
      default:
        return AppLanguage.english; // 默认英文
    }
  }
}

/// 语言状态管理
class LocaleNotifier extends StateNotifier<AppLanguage> {
  final ConfigService _configService = ConfigService.instance;
  bool _isInitialized = false;

  LocaleNotifier() : super(AppLanguage.english) {
    // 不在构造函数中进行异步操作，而是延迟初始化
    _initializeLanguage();
  }

  /// 初始化语言设置
  Future<void> _initializeLanguage() async {
    if (_isInitialized) return;
    _isInitialized = true;
    
    try {
      final languageCode = await _configService.getLanguage();
      state = AppLanguageExtension.fromCode(languageCode);
    } catch (e) {
      print('Failed to load language setting: $e');
      // 保持默认的英文设置
    }
  }

  /// 加载保存的语言设置（保持向后兼容）
  Future<void> _loadLanguage() async {
    await _initializeLanguage();
  }

  /// 设置语言
  Future<void> setLanguage(AppLanguage language) async {
    try {
      await _configService.setLanguage(language.code);
      state = language;
    } catch (e) {
      print('Failed to save language setting: $e');
    }
  }

  /// 获取当前实际使用的Locale
  Locale getCurrentLocale() {
    if (state == AppLanguage.system) {
      // 获取系统语言
      final systemLocale = ui.PlatformDispatcher.instance.locale;
      // 如果系统语言是中文，返回中文，否则返回英文
      if (systemLocale.languageCode == 'zh') {
        return const Locale('zh');
      } else {
        return const Locale('en');
      }
    }
    return state.locale ?? const Locale('en');
  }
}

/// 语言Provider
final localeProvider = StateNotifierProvider<LocaleNotifier, AppLanguage>((ref) {
  return LocaleNotifier();
});

/// 当前Locale Provider
final currentLocaleProvider = Provider<Locale>((ref) {
  final language = ref.watch(localeProvider);
  final notifier = ref.read(localeProvider.notifier);
  return notifier.getCurrentLocale();
}); 