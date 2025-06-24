import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 系统信息小部件
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
            _buildSystemInfoRow('Dart版本', Platform.version.split(' ').first),
            const SizedBox(height: 8),
            _buildSystemInfoRow('可执行文件路径', Platform.resolvedExecutable),
            const SizedBox(height: 16),
            _buildRuntimeStatus(),
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
          ),
        ),
      ],
    );
  }

  Widget _buildRuntimeStatus() {
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
            _buildStatusChip('Python', _checkPythonAvailable()),
            _buildStatusChip('Node.js', _checkNodeAvailable()),
            _buildStatusChip('Git', _checkGitAvailable()),
            _buildStatusChip('UV', _checkUvAvailable()),
          ],
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
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    return 'Unknown';
  }

  String _getProcessorArchitecture() {
    final environment = Platform.environment;
    final arch = environment['PROCESSOR_ARCHITECTURE'] ?? 
                 environment['HOSTTYPE'] ?? 
                 'Unknown';
    return arch;
  }

  bool _checkPythonAvailable() {
    try {
      final result = Process.runSync('python', ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      try {
        final result = Process.runSync('python3', ['--version']);
        return result.exitCode == 0;
      } catch (e) {
        return false;
      }
    }
  }

  bool _checkNodeAvailable() {
    try {
      final result = Process.runSync('node', ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  bool _checkGitAvailable() {
    try {
      final result = Process.runSync('git', ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  bool _checkUvAvailable() {
    try {
      final result = Process.runSync('uv', ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }
} 