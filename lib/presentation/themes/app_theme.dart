import 'package:flutter/material.dart';

/// VS Code风格的应用主题
class AppTheme {
  // VS Code颜色定义
  static const Color vscodeBlue = Color(0xFF007ACC);
  static const Color vscodeGreen = Color(0xFF16825D);
  static const Color vscodeRed = Color(0xFFE14D4D);
  static const Color vscodeOrange = Color(0xFFFF8C00);
  static const Color vscodePurple = Color(0xFF6F42C1);
  
  // 浅色主题颜色
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8F8F8);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE1E4E8);
  static const Color lightText = Color(0xFF24292E);
  static const Color lightTextSecondary = Color(0xFF586069);
  static const Color lightSidebar = Color(0xFFF6F8FA);
  
  // 深色主题颜色
  static const Color darkBackground = Color(0xFF1E1E1E);
  static const Color darkSurface = Color(0xFF252526);
  static const Color darkCardBackground = Color(0xFF2D2D30);
  static const Color darkBorder = Color(0xFF3E3E42);
  static const Color darkText = Color(0xFFCCCCCC);
  static const Color darkTextSecondary = Color(0xFF969696);
  static const Color darkSidebar = Color(0xFF252526);
  
  /// 浅色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: vscodeBlue,
        brightness: Brightness.light,
        primary: vscodeBlue,
        secondary: vscodeGreen,
        error: vscodeRed,
        surface: lightSurface,
      ),
      scaffoldBackgroundColor: lightBackground,
      
      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSidebar,
        foregroundColor: lightText,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: lightText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: lightText),
      ),
      
      // Card主题
      cardTheme: CardThemeData(
        color: lightCardBackground,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      
      // ListTile主题
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: vscodeBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vscodeBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: vscodeBlue,
          side: const BorderSide(color: lightBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: vscodeBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
        space: 1,
      ),
      
      // 滚动条主题
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(lightBorder),
        trackColor: WidgetStateProperty.all(lightSurface),
        thickness: WidgetStateProperty.all(8),
        radius: const Radius.circular(4),
      ),
    );
  }
  
  /// 深色主题
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: vscodeBlue,
        brightness: Brightness.dark,
        primary: vscodeBlue,
        secondary: vscodeGreen,
        error: vscodeRed,
        surface: darkSurface,
      ),
      scaffoldBackgroundColor: darkBackground,
      
      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSidebar,
        foregroundColor: darkText,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: darkText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: darkText),
      ),
      
      // Card主题
      cardTheme: CardThemeData(
        color: darkCardBackground,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      
      // ListTile主题
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        textColor: darkText,
        iconColor: darkText,
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: vscodeBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        labelStyle: const TextStyle(color: darkTextSecondary),
        hintStyle: const TextStyle(color: darkTextSecondary),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vscodeBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: vscodeBlue,
          side: const BorderSide(color: darkBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: vscodeBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),
      
      // 滚动条主题
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(darkBorder),
        trackColor: WidgetStateProperty.all(darkSurface),
        thickness: WidgetStateProperty.all(8),
        radius: const Radius.circular(4),
      ),
    );
  }
  
  /// 状态颜色
  static const Map<String, Color> statusColors = {
    'success': vscodeGreen,
    'warning': vscodeOrange,
    'error': vscodeRed,
    'info': vscodeBlue,
    'secondary': vscodePurple,
  };
  
  /// 获取状态颜色
  static Color getStatusColor(String status) {
    return statusColors[status] ?? vscodeBlue;
  }
} 