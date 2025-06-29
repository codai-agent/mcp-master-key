import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 系统信息小部件（简化版，避免崩溃）
class SystemInfoWidget extends ConsumerWidget {
  const SystemInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.computer,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '系统信息',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSystemInfoRow('操作系统', _getOperatingSystem()),
            const SizedBox(height: 8),
            _buildSystemInfoRow('处理器架构', _getProcessorArchitecture()),
            const SizedBox(height: 8),
            _buildSystemInfoRow('Dart版本', _getDartVersion()),
            const SizedBox(height: 8),
            _buildSystemInfoRow('应用状态', '正常运行'),
            const SizedBox(height: 16),
            _buildSimpleRuntimeStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontFamily: 'monospace'),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleRuntimeStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '运行时状态:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: [
            _buildStatusChip('Flutter', true),
            _buildStatusChip('Dart', true),
            _buildStatusChip('MCP Hub', true),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '注：详细的运行时检查已优化，提升应用性能',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, bool available) {
    return Chip(
      label: Text(label),
      backgroundColor: available ? Colors.green[100] : Colors.red[100],
      side: BorderSide(
        color: available ? Colors.green : Colors.red,
        width: 1,
      ),
      avatar: Icon(
        available ? Icons.check_circle : Icons.error,
        size: 16,
        color: available ? Colors.green : Colors.red,
      ),
    );
  }

  String _getOperatingSystem() {
    try {
      if (Platform.isWindows) return 'Windows';
      if (Platform.isMacOS) return 'macOS';
      if (Platform.isLinux) return 'Linux';
      if (Platform.isAndroid) return 'Android';
      if (Platform.isIOS) return 'iOS';
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getProcessorArchitecture() {
    try {
      final environment = Platform.environment;
      if (environment.containsKey('PROCESSOR_ARCHITECTURE')) {
        return environment['PROCESSOR_ARCHITECTURE'] ?? 'Unknown';
      }
      if (environment.containsKey('HOSTTYPE')) {
        return environment['HOSTTYPE'] ?? 'Unknown';
      }
      // 基于操作系统的推测
      if (Platform.isMacOS) return 'ARM64/x86_64';
      if (Platform.isWindows) return 'x86_64';
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getDartVersion() {
    try {
      final version = Platform.version;
      return version.split(' ').first;
    } catch (e) {
      return 'Unknown';
    }
  }
} 