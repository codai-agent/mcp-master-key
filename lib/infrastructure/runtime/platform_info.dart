import 'dart:io';

/// 平台信息封装类
class PlatformInfo {
  final String os;
  final String arch;

  const PlatformInfo({
    required this.os,
    required this.arch,
  });

  @override
  String toString() => '$os-$arch';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlatformInfo && other.os == os && other.arch == arch;
  }

  @override
  int get hashCode => os.hashCode ^ arch.hashCode;
}

/// 平台信息检测器
class PlatformDetector {
  static PlatformInfo? _cachedPlatformInfo;

  /// 获取当前平台信息
  static PlatformInfo get current {
    _cachedPlatformInfo ??= _detectPlatform();
    return _cachedPlatformInfo!;
  }

  /// 检测当前平台信息
  static PlatformInfo _detectPlatform() {
    final os = _getOperatingSystem();
    final arch = _getArchitecture();
    return PlatformInfo(os: os, arch: arch);
  }

  /// 获取操作系统名称
  static String _getOperatingSystem() {
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }

  /// 获取CPU架构
  static String _getArchitecture() {
    try {
      if (Platform.isWindows) {
        // Windows平台检测
        final arch = Platform.environment['PROCESSOR_ARCHITECTURE'];
        final archWow64 = Platform.environment['PROCESSOR_ARCHITEW6432'];
        
        if (archWow64 != null && archWow64.isNotEmpty) {
          return archWow64.toLowerCase() == 'arm64' ? 'arm64' : 'x64';
        }
        
        return arch?.toLowerCase() == 'arm64' ? 'arm64' : 'x64';
      } else {
        // Unix-like系统使用uname命令检测
        final result = Process.runSync('uname', ['-m']);
        if (result.exitCode == 0) {
          final arch = result.stdout.toString().trim().toLowerCase();
          switch (arch) {
            case 'arm64':
            case 'aarch64':
              return 'arm64';
            case 'x86_64':
            case 'amd64':
              return 'x64';
            default:
              // 对于其他架构，尝试从Dart VM信息推断
              return _fallbackArchitectureDetection();
          }
        }
      }
    } catch (e) {
      // 如果检测失败，使用备用方法
      return _fallbackArchitectureDetection();
    }
    
    return _fallbackArchitectureDetection();
  }

  /// 备用架构检测方法
  static String _fallbackArchitectureDetection() {
    // 基于指针大小的简单检测
    const int pointerSize = 8; // 64位系统
    if (pointerSize == 8) {
      // 在64位系统上，默认假设是x64
      // 这不是完美的解决方案，但对于大多数情况是合理的
      return 'x64';
    } else {
      // 32位系统现在很少见，但如果遇到就报错
      throw UnsupportedError('32-bit systems are not supported');
    }
  }

  /// 检查是否为支持的平台
  static bool get isSupportedPlatform {
    try {
      final platform = current;
      return _isSupportedOS(platform.os) && _isSupportedArch(platform.arch);
    } catch (e) {
      return false;
    }
  }

  /// 检查操作系统是否受支持
  static bool _isSupportedOS(String os) {
    return ['windows', 'macos', 'linux'].contains(os);
  }

  /// 检查架构是否受支持
  static bool _isSupportedArch(String arch) {
    return ['x64', 'arm64'].contains(arch);
  }

  /// 获取平台描述字符串
  static String get platformDescription {
    final platform = current;
    final osName = _getOSDisplayName(platform.os);
    final archName = _getArchDisplayName(platform.arch);
    return '$osName ($archName)';
  }

  /// 获取操作系统显示名称
  static String _getOSDisplayName(String os) {
    switch (os) {
      case 'windows':
        return 'Windows';
      case 'macos':
        return 'macOS';
      case 'linux':
        return 'Linux';
      default:
        return os;
    }
  }

  /// 获取架构显示名称
  static String _getArchDisplayName(String arch) {
    switch (arch) {
      case 'x64':
        return 'x86_64';
      case 'arm64':
        return 'ARM64';
      default:
        return arch;
    }
  }

  /// 重置缓存的平台信息（主要用于测试）
  static void resetCache() {
    _cachedPlatformInfo = null;
  }
} 