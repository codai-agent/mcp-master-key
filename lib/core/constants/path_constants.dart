import 'dart:io';
import 'package:path/path.dart' as path;

/// 路径相关常量定义
class PathConstants {
  // 运行时目录结构
  static const String assetsRuntimesPath = 'assets/runtimes';
  
  // 用户目录相关
  static const String mcpHubDirName = '.mcphub';
  static const String runtimesDirName = 'runtimes';
  static const String serversDirName = 'servers';
  static const String logsDirName = 'logs';
  static const String configDirName = 'config';
  
  // Python相关路径
  static const String pythonDirName = 'python';
  static const String uvDirPrefix = 'uv-';
  static const String pythonDirPrefix = 'python-';
  static const String pythonBinDir = 'bin';
  static const String pythonLibDir = 'lib';
  static const String pythonIncludeDir = 'include';
  static const String pythonShareDir = 'share';
  
  // Node.js相关路径
  static const String nodejsDirName = 'nodejs';
  static const String nodeDirPrefix = 'node-v';
  static const String nodeBinDir = 'bin';
  static const String nodeLibDir = 'lib';
  static const String nodeIncludeDir = 'include';
  static const String nodeShareDir = 'share';
  static const String nodeModulesDir = 'node_modules';
  
  // 可执行文件名
  static const String pythonExeName = 'python';
  static const String python3ExeName = 'python3';
  static const String pipExeName = 'pip';
  static const String pip3ExeName = 'pip3';
  static const String uvExeName = 'uv';
  static const String uvxExeName = 'uvx';
  static const String nodeExeName = 'node';
  static const String npmExeName = 'npm';
  static const String npxExeName = 'npx';
  static const String corepackExeName = 'corepack';
  
  // 平台特定扩展名
  static String getExecutableExtension() {
    return Platform.isWindows ? '.exe' : '';
  }
  
  static String getScriptExtension() {
    return Platform.isWindows ? '.cmd' : '';
  }
  
  // 平台名称映射
  static String getPlatformName() {
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }
  
  // 架构名称映射
  static String getArchitectureName() {
    // 通过不同方式检测CPU架构
    if (Platform.isWindows) {
      return Platform.environment['PROCESSOR_ARCHITECTURE'] == 'ARM64' 
          ? 'arm64' : 'x64';
    } else if (Platform.isMacOS) {
      // 运行 uname -m 来检测
      final result = Process.runSync('uname', ['-m']);
      return result.stdout.toString().trim() == 'arm64' ? 'arm64' : 'x64';
    } else if (Platform.isLinux) {
      final result = Process.runSync('uname', ['-m']);
      final arch = result.stdout.toString().trim();
      return (arch == 'aarch64' || arch == 'arm64') ? 'arm64' : 'x64';
    }
    return 'x64'; // 默认
  }
  
  // 用户目录路径获取
  static String getUserHomeDirectory() {
    return Platform.environment['HOME'] ?? 
           Platform.environment['USERPROFILE'] ?? 
           '/tmp';
  }
  
  static String getUserMcpHubPath() {
    return path.join(getUserHomeDirectory(), mcpHubDirName);
  }
  
  static String getUserRuntimesPath() {
    return path.join(getUserMcpHubPath(), runtimesDirName);
  }
  
  static String getUserServersPath() {
    return path.join(getUserMcpHubPath(), serversDirName);
  }
  
  static String getUserLogsPath() {
    return path.join(getUserMcpHubPath(), logsDirName);
  }
  
  static String getUserConfigPath() {
    return path.join(getUserMcpHubPath(), configDirName);
  }

  // 构建运行时路径
  static String buildRuntimePath(List<String> components) {
    String result = assetsRuntimesPath;
    for (final component in components) {
      result = '$result/$component';
    }
    return result;
  }
  
  // 构建用户运行时路径
  static String buildUserRuntimePath(List<String> components) {
    String result = getUserRuntimesPath();
    for (final component in components) {
      result = path.join(result, component);
    }
    return result;
  }
  
  // 构建Python运行时路径
  static String buildPythonRuntimePath(String version) {
    return buildRuntimePath([
      pythonDirName,
      getPlatformName(),
      getArchitectureName(),
      '$pythonDirPrefix$version'
    ]);
  }
  
  // 构建UV运行时路径
  static String buildUvRuntimePath(String version) {
    return buildRuntimePath([
      pythonDirName,
      getPlatformName(),
      getArchitectureName(),
      '$uvDirPrefix$version'
    ]);
  }
  
  // 构建Node.js运行时路径
  static String buildNodeRuntimePath(String version) {
    return buildRuntimePath([
      nodejsDirName,
      getPlatformName(),
      getArchitectureName(),
      '$nodeDirPrefix$version'
    ]);
  }
  
  // 环境相关路径
  static const String virtualEnvDir = 'venv';
  static const String packageJsonFile = 'package.json';
  static const String packageLockJsonFile = 'package-lock.json';
  static const String yarnLockFile = 'yarn.lock';
  static const String pnpmLockFile = 'pnpm-lock.yaml';
  static const String requirementsTxtFile = 'requirements.txt';
  static const String pyprojectTomlFile = 'pyproject.toml';
  static const String setupPyFile = 'setup.py';
  static const String poetryLockFile = 'poetry.lock';
} 