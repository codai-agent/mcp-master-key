import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/market_server_model.dart';
import '../../l10n/generated/app_localizations.dart';

/// MCP服务详情页面
class McpServerDetailPage extends StatelessWidget {
  final MarketServerModel server;

  const McpServerDetailPage({
    super.key,
    required this.server,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(server.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 服务头部信息
            _buildServerHeader(context, l10n),
            
            const SizedBox(height: 24),
            
            // 描述部分
            _buildDescriptionSection(context, l10n),
            
            const SizedBox(height: 24),
            
            // 标签部分
            if (server.tags.isNotEmpty) ...[
              _buildTagsSection(context, l10n),
              const SizedBox(height: 24),
            ],
            
            // 统计信息
            _buildStatsSection(context, l10n),
            
            const SizedBox(height: 24),
            
            // MCP配置
            if (server.mcpConfig != null && server.mcpConfig!.isNotEmpty) ...[
              _buildMcpConfigSection(context, l10n),
              const SizedBox(height: 24),
            ],
            
            // 链接部分
            _buildLinksSection(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildServerHeader(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: server.logoUrl != null
                  ? Image.network(
                      server.logoUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultLogo(80);
                      },
                    )
                  : _buildDefaultLogo(80),
            ),
            
            const SizedBox(width: 16),
            
            // 服务信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    server.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    '${l10n.market_author}: ${server.author}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 简短描述
                  Text(
                    server.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.market_description,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              server.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.market_tags,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: server.tags.map((tag) => Chip(
                label: Text(
                  tag,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.blue[50],
                side: BorderSide(color: Colors.blue[200]!, width: 1),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.market_statistics,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.download,
                    l10n.market_download_count,
                    server.downloadCount.toString(),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.people,
                    l10n.market_used_count,
                    server.usedCount.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.blue[600]),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMcpConfigSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.market_mcp_config,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const Spacer(),
                
                TextButton.icon(
                  onPressed: () => _copyToClipboard(context, server.mcpConfig!),
                  icon: const Icon(Icons.copy, size: 16),
                  label: Text(l10n.market_copy_config),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  server.mcpConfig!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinksSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.market_links,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            ListTile(
              leading: Image.asset(
                'assets/images/github.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.code, size: 24);
                },
              ),
              title: Text(l10n.market_view_github),
              subtitle: Text(server.githubUrl),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchUrl(server.githubUrl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultLogo(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.extension,
        color: Colors.blue,
        size: size * 0.5,
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.market_config_copied),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
} 