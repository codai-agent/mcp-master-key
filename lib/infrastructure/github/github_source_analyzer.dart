import 'dart:convert';
import 'package:dio/dio.dart';

/// GitHub仓库信息
class GitHubRepository {
  final String owner;
  final String name;
  final String? branch;
  final String? subPath;
  final String fullName;
  final String cloneUrl;
  final String? description;

  GitHubRepository({
    required this.owner,
    required this.name,
    this.branch,
    this.subPath,
    required this.fullName,
    required this.cloneUrl,
    this.description,
  });

  factory GitHubRepository.fromUrl(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    
    if (pathSegments.length < 2) {
      throw ArgumentError('Invalid GitHub URL: $url');
    }
    
    final owner = pathSegments[0];
    final name = pathSegments[1].replaceAll('.git', '');
    String? branch;
    String? subPath;
    
    // 解析分支和子路径
    if (pathSegments.length > 2) {
      if (pathSegments[2] == 'tree' && pathSegments.length > 3) {
        branch = pathSegments[3];
        if (pathSegments.length > 4) {
          subPath = pathSegments.skip(4).join('/');
        }
      }
    }
    
    return GitHubRepository(
      owner: owner,
      name: name,
      branch: branch ?? 'main',
      subPath: subPath,
      fullName: '$owner/$name',
      cloneUrl: 'https://github.com/$owner/$name.git',
    );
  }
}

/// 项目类型
enum ProjectType {
  python,
  nodejs,
  typescript,
  unknown,
}

/// 项目分析结果
class ProjectAnalysisResult {
  final ProjectType type;
  final String? packageName;
  final String? version;
  final List<String> installCommands;
  final Map<String, dynamic> metadata;
  final List<String> dependencies;
  final String? buildCommand;
  final String? startCommand;

  ProjectAnalysisResult({
    required this.type,
    this.packageName,
    this.version,
    required this.installCommands,
    this.metadata = const {},
    this.dependencies = const [],
    this.buildCommand,
    this.startCommand,
  });
}

/// GitHub源码分析器
class GitHubSourceAnalyzer {
  final Dio _dio;
  
  GitHubSourceAnalyzer() : _dio = Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'MCP-Hub/1.0.0',
    };
  }

  /// 分析GitHub仓库
  Future<ProjectAnalysisResult> analyzeRepository(String url) async {
    final repo = GitHubRepository.fromUrl(url);
    
    // 获取仓库内容
    final contents = await _getRepositoryContents(repo);
    
    // 检测项目类型
    final projectType = _detectProjectType(contents);
    
    // 根据项目类型进行具体分析
    switch (projectType) {
      case ProjectType.python:
        return await _analyzePythonProject(repo, contents);
      case ProjectType.nodejs:
      case ProjectType.typescript:
        return await _analyzeNodeProject(repo, contents);
      default:
        return ProjectAnalysisResult(
          type: ProjectType.unknown,
          installCommands: [],
          metadata: {'error': 'Unknown project type'},
        );
    }
  }

  /// 获取仓库内容
  Future<Map<String, dynamic>> _getRepositoryContents(GitHubRepository repo) async {
    final contents = <String, dynamic>{};
    
    try {
      // 获取根目录文件列表
      final pathParam = repo.subPath ?? '';
      final response = await _dio.get(
        'https://api.github.com/repos/${repo.fullName}/contents/$pathParam',
        queryParameters: {
          if (repo.branch != null) 'ref': repo.branch,
        },
      );
      
      final files = response.data as List<dynamic>;
      
      // 获取关键文件内容
      for (final file in files) {
        final fileName = file['name'] as String;
        final fileType = file['type'] as String;
        
        if (fileType == 'file' && _isImportantFile(fileName)) {
          try {
            final fileContent = await _getFileContent(repo, fileName);
            contents[fileName] = fileContent;
          } catch (e) {
            // 忽略单个文件获取失败，继续处理其他文件
          }
        }
      }
      
      return contents;
    } catch (e) {
      throw Exception('Failed to get repository contents: $e');
    }
  }

  /// 获取文件内容
  Future<String> _getFileContent(GitHubRepository repo, String fileName) async {
    final subPathPrefix = repo.subPath != null ? '${repo.subPath}/' : '';
    final response = await _dio.get(
      'https://api.github.com/repos/${repo.fullName}/contents/$subPathPrefix$fileName',
      queryParameters: {
        if (repo.branch != null) 'ref': repo.branch,
      },
    );
    
    final content = response.data['content'] as String;
    final encoding = response.data['encoding'] as String;
    
    if (encoding == 'base64') {
      return utf8.decode(base64.decode(content));
    } else {
      return content;
    }
  }

  /// 检测项目类型
  ProjectType _detectProjectType(Map<String, dynamic> contents) {
    // Python项目检测
    if (contents.containsKey('pyproject.toml') ||
        contents.containsKey('setup.py') ||
        contents.containsKey('requirements.txt') ||
        contents.containsKey('Pipfile') ||
        contents.containsKey('poetry.lock')) {
      return ProjectType.python;
    }
    
    // Node.js/TypeScript项目检测
    if (contents.containsKey('package.json')) {
      final packageJson = contents['package.json'] as String?;
      if (packageJson != null) {
        try {
          final parsed = jsonDecode(packageJson) as Map<String, dynamic>;
          final devDeps = parsed['devDependencies'] as Map<String, dynamic>?;
          if (devDeps?.containsKey('typescript') == true ||
              devDeps?.containsKey('@types/node') == true) {
            return ProjectType.typescript;
          }
        } catch (e) {
          // 解析失败，按Node.js处理
        }
      }
      return ProjectType.nodejs;
    }
    
    return ProjectType.unknown;
  }

  /// 分析Python项目
  Future<ProjectAnalysisResult> _analyzePythonProject(
    GitHubRepository repo,
    Map<String, dynamic> contents,
  ) async {
    String? packageName;
    String? version;
    final dependencies = <String>[];
    final installCommands = <String>[];
    final metadata = <String, dynamic>{};

    // 分析pyproject.toml
    if (contents.containsKey('pyproject.toml')) {
      final pyprojectContent = contents['pyproject.toml'] as String;
      metadata['pyproject.toml'] = pyprojectContent;
      
      // 简单的TOML解析（仅提取基本信息）
      final lines = pyprojectContent.split('\n');
      for (final line in lines) {
        if (line.trim().startsWith('name =')) {
          packageName = _extractQuotedValue(line);
        } else if (line.trim().startsWith('version =')) {
          version = _extractQuotedValue(line);
        }
      }
      
      // Poetry项目
      if (pyprojectContent.contains('[tool.poetry]')) {
        installCommands.add('poetry install');
        final mainModule = packageName ?? 'main';
        installCommands.add('poetry run python -m $mainModule');
      } else {
        // 标准pip项目
        installCommands.addAll([
          'pip install -e .',
        ]);
      }
    }
    
    // 分析setup.py
    else if (contents.containsKey('setup.py')) {
      final setupContent = contents['setup.py'] as String;
      metadata['setup.py'] = setupContent;
      
      // 提取包名（简单正则匹配）
      final namePattern = RegExp(r'name\s*=\s*["\x27]([^"\x27]+)["\x27]');
      final nameMatch = namePattern.firstMatch(setupContent);
      if (nameMatch != null) {
        packageName = nameMatch.group(1);
      }
      
      installCommands.addAll([
        'pip install -e .',
      ]);
    }
    
    // 分析requirements.txt
    if (contents.containsKey('requirements.txt')) {
      final reqContent = contents['requirements.txt'] as String;
      dependencies.addAll(
        reqContent.split('\n')
            .where((line) => line.trim().isNotEmpty && !line.startsWith('#'))
            .toList(),
      );
      
      if (installCommands.isEmpty) {
        installCommands.addAll([
          'pip install -r requirements.txt',
        ]);
      }
    }

    return ProjectAnalysisResult(
      type: ProjectType.python,
      packageName: packageName,
      version: version,
      installCommands: installCommands,
      dependencies: dependencies,
      metadata: metadata,
    );
  }

  /// 分析Node.js项目
  Future<ProjectAnalysisResult> _analyzeNodeProject(
    GitHubRepository repo,
    Map<String, dynamic> contents,
  ) async {
    final packageJsonContent = contents['package.json'] as String;
    final packageJson = jsonDecode(packageJsonContent) as Map<String, dynamic>;
    
    final packageName = packageJson['name'] as String?;
    final version = packageJson['version'] as String?;
    final scripts = packageJson['scripts'] as Map<String, dynamic>?;
    final dependencies = <String>[];
    final installCommands = <String>[];
    
    // 提取依赖
    final deps = packageJson['dependencies'] as Map<String, dynamic>?;
    final devDeps = packageJson['devDependencies'] as Map<String, dynamic>?;
    
    if (deps != null) {
      dependencies.addAll(deps.keys);
    }
    if (devDeps != null) {
      dependencies.addAll(devDeps.keys);
    }
    
    // 检测包管理器
    String packageManager = 'npm';
    if (contents.containsKey('yarn.lock')) {
      packageManager = 'yarn';
    } else if (contents.containsKey('pnpm-lock.yaml')) {
      packageManager = 'pnpm';
    }
    
    // 生成安装命令
    switch (packageManager) {
      case 'yarn':
        installCommands.add('yarn install');
        if (scripts?.containsKey('build') == true) {
          installCommands.add('yarn build');
        }
        break;
      case 'pnpm':
        installCommands.add('pnpm install');
        if (scripts?.containsKey('build') == true) {
          installCommands.add('pnpm build');
        }
        break;
      default:
        installCommands.add('npm install');
        if (scripts?.containsKey('build') == true) {
          installCommands.add('npm run build');
        }
    }

    // 构建命令和启动命令
    String? buildCommand;
    String? startCommand;
    
    if (scripts?.containsKey('build') == true) {
      buildCommand = _getBuildCommand(packageManager);
    }
    
    if (scripts?.containsKey('start') == true) {
      startCommand = _getStartCommand(packageManager);
    }

    return ProjectAnalysisResult(
      type: contents.containsKey('tsconfig.json') ? ProjectType.typescript : ProjectType.nodejs,
      packageName: packageName,
      version: version,
      installCommands: installCommands,
      dependencies: dependencies,
      buildCommand: buildCommand,
      startCommand: startCommand,
      metadata: {
        'packageManager': packageManager,
        'scripts': scripts ?? {},
      },
    );
  }

  /// 检查是否是重要文件
  bool _isImportantFile(String fileName) {
    const importantFiles = {
      'package.json',
      'pyproject.toml',
      'setup.py',
      'requirements.txt',
      'Pipfile',
      'poetry.lock',
      'yarn.lock',
      'pnpm-lock.yaml',
      'tsconfig.json',
      'README.md',
      'Dockerfile',
    };
    
    return importantFiles.contains(fileName);
  }

  /// 提取引号中的值
  String? _extractQuotedValue(String line) {
    final match = RegExp(r'["\x27]([^"\x27]+)["\x27]').firstMatch(line);
    return match?.group(1);
  }

  /// 获取构建命令
  String _getBuildCommand(String packageManager) {
    if (packageManager == 'npm') {
      return 'npm run build';
    } else {
      return '$packageManager build';
    }
  }

  /// 获取启动命令
  String _getStartCommand(String packageManager) {
    if (packageManager == 'npm') {
      return 'npm run start';
    } else {
      return '$packageManager start';
    }
  }

  /// 释放资源
  void dispose() {
    _dio.close();
  }
} 