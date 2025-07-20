import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/market_server_model.dart';
import '../../business/services/mcp_market_service.dart';
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
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final String searchQuery;
  final String? selectedCategory;
  final bool hasNextPage;

  MarketServerState({
    this.servers = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalCount = 0,
    this.searchQuery = '',
    this.selectedCategory,
    this.hasNextPage = true,
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
  }) {
    return MarketServerState(
      servers: servers ?? this.servers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}

class MarketServerNotifier extends StateNotifier<MarketServerState> {
  MarketServerNotifier() : super(MarketServerState()) {
    loadServers();
  }

  final _service = McpMarketService.instance;

  Future<void> loadServers({
    int? page,
    String? search,
    String? category,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _service.getServers(
        page: page ?? state.currentPage,
        search: search ?? state.searchQuery,
        category: category ?? state.selectedCategory,
        size: 12,
      );

      final totalPages = (response.data.total / 12).ceil();
      final hasNextPage = response.data.items.length == 12; // 如果返回了12个项目，可能还有下一页

      state = state.copyWith(
        servers: response.data.items,
        isLoading: false,
        currentPage: response.data.page,
        totalPages: totalPages,
        totalCount: response.data.total,
        searchQuery: search ?? state.searchQuery,
        selectedCategory: category ?? state.selectedCategory,
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
    state = state.copyWith(searchQuery: query, currentPage: 1, hasNextPage: true);
    loadServers(page: 1, search: query);
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category, currentPage: 1, hasNextPage: true);
    loadServers(page: 1, category: category);
  }

  void nextPage() async {
    if (state.hasNextPage) {
      final currentPage = state.currentPage;
      try {
        final response = await _service.getServers(
          page: currentPage + 1,
          search: state.searchQuery,
          category: state.selectedCategory,
          size: 12,
        );
        
        // 如果下一页没有数据，保持当前页不变，标记没有下一页
        if (response.data.items.isEmpty) {
          state = state.copyWith(hasNextPage: false);
        } else {
          // 有数据，正常更新到下一页
          final totalPages = (response.data.total / 12).ceil();
          final hasNextPage = response.data.items.length == 12;
          
          state = state.copyWith(
            servers: response.data.items,
            currentPage: currentPage + 1,
            totalPages: totalPages,
            totalCount: response.data.total,
            hasNextPage: hasNextPage,
          );
        }
      } catch (e) {
        // 发生错误时，标记没有下一页
        state = state.copyWith(hasNextPage: false);
      }
    }
  }

  void previousPage() async {
    if (state.currentPage > 1) {
      try {
        final response = await _service.getServers(
          page: state.currentPage - 1,
          search: state.searchQuery,
          category: state.selectedCategory,
          size: 12,
        );
        
        final totalPages = (response.data.total / 12).ceil();
        final hasNextPage = response.data.items.length == 12;
        
        state = state.copyWith(
          servers: response.data.items,
          currentPage: state.currentPage - 1,
          totalPages: totalPages,
          totalCount: response.data.total,
          hasNextPage: hasNextPage,
          isLoading: false,
        );
      } catch (e) {
        state = state.copyWith(
          error: e.toString(),
          isLoading: false,
        );
      }
    }
  }

  void refresh() {
    loadServers();
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

  @override
  void initState() {
    super.initState();
    // 监听搜索框内容变化
    _searchController.addListener(() {
      setState(() {}); // 确保清空按钮的显示状态正确更新
      
      // 只有当搜索框变空时才自动触发查询
      if (_searchController.text.isEmpty) {
        ref.read(marketServerProvider.notifier).setSearchQuery('');
      }
    });
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
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                childAspectRatio: 1.2,
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
          
          const SizedBox(height: 6),
          
          // 描述
          Tooltip(
            message: server.description,
            child: Text(
              server.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
              maxLines: 5,
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
    
    try {
      // 这里应该调用安装服务来安装服务器
      // 暂时模拟安装过程
      
      // 增加使用计数
      await McpMarketService.instance.incrementUsedCount(server.mcpId);
      
      // 标记为已安装
      setState(() {
        _installedServers.add(server.mcpId);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.market_install_success),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.market_install_failed),
            backgroundColor: Colors.red,
          ),
        );
      }
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