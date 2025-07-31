import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/market_server_model.dart';
import '../../business/services/mcp_market_service.dart';
import '../../business/services/mcp_server_service.dart';
import '../../business/services/install_service.dart';
import '../../business/parsers/mcp_config_parser.dart';
import '../../core/models/mcp_server.dart';
import '../../core/constants/app_constants.dart';
import '../../infrastructure/repositories/mcp_server_repository.dart';
import '../../l10n/generated/app_localizations.dart';

/// MCP市场状态提供者
final marketServerProvider = StateNotifierProvider<MarketServerNotifier, MarketServerState>((ref) {
  return MarketServerNotifier();
});

final marketCategoriesProvider = FutureProvider<List<MarketCategoryModel>>((ref) async {
  final service = McpMarketService.instance;
  final response = await service.getCategories();
  return response.data;
});

class MarketServerState {
  final List<MarketServerModel> servers;
  final bool isLoading;
  final String? error;
  final int totalPages;
  final int totalCount;
  final bool hasNextPage;
  
  // 查询参数组 - 这是查询的唯一来源
  final int currentPage;
  final String searchQuery;
  final String? selectedCategory;

  MarketServerState({
    this.servers = const [],
    this.isLoading = false,
    this.error,
    this.totalPages = 1,
    this.totalCount = 0,
    this.hasNextPage = true,
    // 查询参数
    this.currentPage = 1,
    this.searchQuery = '',
    this.selectedCategory,
  });

  MarketServerState copyWith({
    List<MarketServerModel>? servers,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    String? searchQuery,
    String? selectedCategory,
    bool? hasNextPage,
    bool? clearSelectedCategory, // 新增参数，用于明确清空selectedCategory
  }) {
    return MarketServerState(
      servers: servers ?? this.servers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearSelectedCategory == true ? null : (selectedCategory ?? this.selectedCategory),
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}

class MarketServerNotifier extends StateNotifier<MarketServerState> {
  MarketServerNotifier() : super(MarketServerState()) {
    _executeQuery(); // 初始加载
  }

  final _service = McpMarketService.instance;

  // 简化的加载方法 - 始终使用state中的查询参数
  Future<void> _executeQuery() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {

      
      final response = await _service.getServers(
        page: state.currentPage,
        search: state.searchQuery,
        category: state.selectedCategory,
        size: 9,
      );

      final totalPages = (response.data.total / 9).ceil();
      final hasNextPage = response.data.items.length == 9;

      state = state.copyWith(
        servers: response.data.items,
        isLoading: false,
        totalPages: totalPages,
        totalCount: response.data.total,
        hasNextPage: hasNextPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setSearchQuery(String query) {
    // 更新查询参数并重新查询
    state = state.copyWith(searchQuery: query, currentPage: 1, hasNextPage: true);
    _executeQuery();
  }

  void setCategory(String? category) {
    // 更新查询参数并重新查询
    if (category == null) {
      // 明确清空selectedCategory
      state = state.copyWith(clearSelectedCategory: true, currentPage: 1, hasNextPage: true);
    } else {
      // 设置具体的category值
      state = state.copyWith(selectedCategory: category, currentPage: 1, hasNextPage: true);
    }
    
    _executeQuery();
  }

  void nextPage() async {
    if (state.hasNextPage && !state.isLoading) {
      // 更新页码并查询
      state = state.copyWith(currentPage: state.currentPage + 1);
      await _executeQuery();
    }
  }

  void previousPage() async {
    if (state.currentPage > 1 && !state.isLoading) {
      // 更新页码并查询
      state = state.copyWith(currentPage: state.currentPage - 1);
      await _executeQuery();
    }
  }

  void refresh() {
    _executeQuery();
  }
}

/// MCP服务商店页面
class McpMarketPage extends ConsumerStatefulWidget {
  const McpMarketPage({super.key});

  @override
  ConsumerState<McpMarketPage> createState() => _McpMarketPageState();
}

class _McpMarketPageState extends ConsumerState<McpMarketPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _installedServers = <String>{}; // 已安装服务器的ID集合
  bool _installedServersLoaded = false;

  @override
  void initState() {
    super.initState();
    
    // 加载已安装的服务器列表
    _loadInstalledServers();
    
    // 监听搜索框内容变化
    _searchController.addListener(() {
      setState(() {}); // 确保清空按钮的显示状态正确更新
      
      // 只有当搜索框变空时才自动触发查询
      if (_searchController.text.isEmpty) {
        ref.read(marketServerProvider.notifier).setSearchQuery('');
      }
    });
  }

  /// 加载已安装的服务器列表
  Future<void> _loadInstalledServers() async {
    if (_installedServersLoaded) return;
    
    try {
      final serverService = McpServerService.instance;
      final allServers = await serverService.getAllServers();
      
      // 筛选出从应用商店安装的服务器
      final marketInstalledServers = allServers
          .where((s) => s.installSourceType == AppConstants.installSourceMarket)
          .toList();
      
      setState(() {
        _installedServers.clear();
        // 对于应用商店安装的服务器，使用服务器ID（应该是mcpId）
        _installedServers.addAll(marketInstalledServers.map((s) => s.id));
        _installedServersLoaded = true;
      });
      
      print('📋 Loaded ${_installedServers.length} installed market servers');
    } catch (e) {
      print('❌ Failed to load installed servers: $e');
      setState(() {
        _installedServersLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final marketState = ref.watch(marketServerProvider);
    final categoriesAsync = ref.watch(marketCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.market_title),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // 搜索和筛选区域
          _buildSearchAndFilter(l10n, categoriesAsync),
          
          // 内容区域
          Expanded(
            child: _buildContent(l10n, marketState),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(AppLocalizations l10n, AsyncValue<List<MarketCategoryModel>> categoriesAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // 搜索框
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.market_search_hint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                          // 清空时会自动触发监听器中的查询逻辑，无需重复调用
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (query) {
                ref.read(marketServerProvider.notifier).setSearchQuery(query);
              },
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 类别筛选下拉框
          Expanded(
            flex: 1,
            child: categoriesAsync.when(
              data: (categories) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                hint: Text(l10n.market_all_categories),
                value: ref.watch(marketServerProvider).selectedCategory,
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(l10n.market_all_categories),
                  ),
                  ...categories.map((category) => DropdownMenuItem<String>(
                    value: category.code,
                    child: Text(
                      Localizations.localeOf(context).languageCode == 'zh' 
                          ? category.name 
                          : category.code,
                    ),
                  )),
                ],
                onChanged: (value) {
                  ref.read(marketServerProvider.notifier).setCategory(value);
                },
              ),
              loading: () => const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(l10n.market_load_error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, MarketServerState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(l10n.market_load_error),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(marketServerProvider.notifier).refresh();
              },
              child: Text(l10n.market_retry),
            ),
          ],
        ),
      );
    }

    if (state.servers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.market_no_results),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 服务器网格
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 固定3列
                childAspectRatio: 1.5, // 增大比值，使卡片高度变短
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: state.servers.length,
              itemBuilder: (context, index) {
                final server = state.servers[index];
                return _buildServerCard(l10n, server);
              },
            ),
          ),
        ),
        
        // 分页控件
        _buildPagination(l10n, state),
      ],
    );
  }

  Widget _buildServerCard(AppLocalizations l10n, MarketServerModel server) {
    final isInstalled = _installedServers.contains(server.mcpId);
    
    return IntrinsicHeight(
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // 头部：Logo、名称、作者
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: server.logoUrl != null
                        ? Image.network(
                            server.logoUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultLogo();
                            },
                          )
                        : _buildDefaultLogo(),
                  ),

                  const SizedBox(width: 8),

                  // 名称和作者
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          server.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          server.author,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 插入tags展示
              if (server.tags.isNotEmpty) ...[
                const SizedBox(height: 3),
                SizedBox(
                  height: 36, // 限制高度，防止overflow
                  child: Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    children: server.tags.take(4).map((tag) => // 最多显示6个标签
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue[200]!, width: 0.5),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 3),
              // 描述
              Tooltip(
                message: server.description,
                child: Text(
                  server.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const Expanded(child: SizedBox()),

              // 底部菜单
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    // GitHub图标
                    GestureDetector(
                      onTap: () => _launchUrl(server.githubUrl),
                      child: Tooltip(
                        message: l10n.market_view_github,
                        child: Image.asset(
                          'assets/images/github.png',
                          width: 14,
                          height: 14,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.code, size: 14);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // 下载量
                    Expanded(
                      child: _buildStatChip(
                        Icons.download,
                        '${server.downloadCount}',
                        l10n.market_download_count,
                      ),
                    ),

                    const SizedBox(width: 4),

                    // 使用量
                    Expanded(
                      child: _buildStatChip(
                        Icons.people,
                        '${server.usedCount}',
                        l10n.market_used_count,
                      ),
                    ),

                    const SizedBox(width: 6),

                    // 安装按钮
                    SizedBox(
                      height: 24,
                      child: ElevatedButton(
                        onPressed: isInstalled ? null : () => _installServer(server),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          textStyle: const TextStyle(fontSize: 10),
                          minimumSize: const Size(50, 24),
                        ),
                        child: Text(
                          isInstalled ? l10n.market_installed : l10n.market_install,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(
        Icons.extension,
        color: Colors.blue,
        size: 20,
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 9, color: Colors.grey[600]),
            const SizedBox(width: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _installServer(MarketServerModel server) async {
    final l10n = AppLocalizations.of(context)!;
    
    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(l10n.market_installing_server),
          ],
        ),
      ),
    );
    
    try {
      // 1. 检查是否已经安装
      final serverService = McpServerService.instance;
      final allServers = await serverService.getAllServers();
      final existingServer = allServers.firstWhere(
        (s) => s.id == server.mcpId || 
               (s.installSourceType == AppConstants.installSourceMarket && 
                s.name == server.name),
        orElse: () => throw Exception('not_found'),
      );
      
      // 如果找到了现有服务器，说明已安装
      if (mounted) Navigator.of(context).pop(); // 关闭加载对话框
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('服务器已安装：${existingServer.name}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
      
    } catch (e) {
      // 没有找到现有服务器，继续安装
    }
    
    try {
      // 2. 解析MCP配置（与手动安装向导完全一致）
      final mcpConfig = server.mcpConfig;
      if (mcpConfig == null || mcpConfig.isEmpty) {
        throw Exception('服务器配置为空');
      }
      
      // 使用MCP配置解析器解析配置
      final parser = McpConfigParser.instance;
      final parseResult = parser.parseConfig(mcpConfig);
      
      if (!parseResult.success || parseResult.servers.isEmpty) {
        throw Exception('配置解析失败：${parseResult.error ?? "未知错误"}');
      }
      
      // 获取第一个服务器配置（通常只有一个）
      final serverConfig = parseResult.servers.first;
      
      print('📋 解析到的服务器配置：');
      print('   - 名称: ${serverConfig.name}');
      print('   - 命令: ${serverConfig.command}');
      print('   - 参数: ${serverConfig.args.join(' ')}');
      print('   - 安装类型: ${serverConfig.installType.name}');
      print('   - 环境变量: ${serverConfig.env}');
      
      // 3. 创建临时服务器对象用于安装
      final tempServer = McpServer(
        id: server.mcpId,//'temp_${DateTime.now().millisecondsSinceEpoch}',
        name: serverConfig.name,
        command: serverConfig.command,
        args: serverConfig.args,
        env: serverConfig.env,
        installType: serverConfig.installType,
        connectionType: serverConfig.connectionType,
        workingDirectory: serverConfig.workingDirectory,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // 4. 执行安装
      final installService = InstallService.instance;
      final installResult = await installService.installServer(tempServer);
      
      if (!installResult.success) {
        // 不在这里关闭对话框，让外层catch统一处理
        throw Exception('安装失败：${installResult.errorMessage}');
      }
      
      // 5. 添加服务器到数据库（使用解析出的配置）
      final serverService = McpServerService.instance;
      await serverService.addServer(
        name: serverConfig.name,
        description: server.description,
        command: serverConfig.command,
        args: serverConfig.args,
        env: serverConfig.env,
        workingDirectory: serverConfig.workingDirectory,
        installType: serverConfig.installType,
        installSource: server.githubUrl,
        installSourceType: AppConstants.installSourceMarket, // 应用商店安装
        autoStart: false,
              );
        
        // 6. 找到刚添加的服务器
        final allServers = await serverService.getAllServers();
        final addedServer = allServers.firstWhere(
          (s) => s.name == serverConfig.name &&
                 s.installSourceType == AppConstants.installSourceMarket,
          orElse: () => throw Exception('无法找到刚添加的服务器'),
        );
        
        // 7. 重要：修改服务器ID为mcpId并更新到数据库
        await _updateServerIdToMcpId(addedServer, server.mcpId);
        
        // 8. 更新服务器状态为已安装
        await serverService.updateServerStatus(server.mcpId, McpServerStatus.installed);
        
        // 9. 增加下载计数
        await McpMarketService.instance.incrementDownloadCount(server.mcpId);
      
      // 10. 更新本地已安装列表
      setState(() {
        _installedServers.add(server.mcpId);
      });
      
      if (mounted) Navigator.of(context).pop(); // 关闭加载对话框
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.market_install_success),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // 关闭加载对话框
      
      print('❌ Market installation failed: $e');
      
      if (mounted) {
        // 提取异常消息，避免双重前缀
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11); // 移除 "Exception: " 前缀
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5), // 延长显示时间，让用户能看清错误
          ),
        );
      }
    }
  }

  /// 更新服务器ID为mcpId（重要：应用商店安装的服务器需要使用mcpId作为数据库ID）
  Future<void> _updateServerIdToMcpId(McpServer server, String mcpId) async {
    try {
      final repository = McpServerRepository.instance;
      
      // 1. 先删除旧的服务器记录
      await repository.deleteServer(server.id);
      
      // 2. 创建新的服务器记录，使用mcpId作为ID
      final updatedServer = server.copyWith(
        id: mcpId,
        updatedAt: DateTime.now(),
      );
      
      // 3. 插入新记录
      await repository.insertServer(updatedServer);
      
      print('✅ Updated server ID from ${server.id} to $mcpId for market installation');
      
    } catch (e) {
      print('❌ Failed to update server ID: $e');
      throw Exception('更新服务器ID失败：$e');
    }
  }

  Widget _buildPagination(AppLocalizations l10n, MarketServerState state) {
    // 为了测试，暂时显示分页控件即使只有1页
    // if (state.totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 页面信息
          Text(
            '第 ${state.currentPage} 页',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          
          // 分页按钮
          Row(
            children: [
              ElevatedButton(
                onPressed: state.currentPage > 1
                    ? () => ref.read(marketServerProvider.notifier).previousPage()
                    : null,
                child: Text(l10n.market_previous_page),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: state.hasNextPage
                    ? () => ref.read(marketServerProvider.notifier).nextPage()
                    : null,
                child: Text(l10n.market_next_page),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 