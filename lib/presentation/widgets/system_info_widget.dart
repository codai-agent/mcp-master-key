import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 系统信息小部件
class SystemInfoWidget extends ConsumerStatefulWidget {
  const SystemInfoWidget({super.key});

  @override
  ConsumerState<SystemInfoWidget> createState() => _SystemInfoWidgetState();
}

class _SystemInfoWidgetState extends ConsumerState<SystemInfoWidget> {
  // 缓存系统状态，避免重复检查
  Map<String, bool>? _runtimeStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkRuntimeStatus();
  }

  Future<void> _checkRuntimeStatus() async {
    if (!mounted) return;
    
    try {
      final status = <String, bool>{};
      
      // 异步检查各个运行时
      final futures = [
        _checkPythonAvailableAsync().then((value) => status['Python'] = value),
        _checkNodeAvailableAsync().then((value) => status['Node.js'] = value),
        _checkGitAvailableAsync().then((value) => status['Git'] = value),
        _checkUvAvailableAsync().then((value) => status['UV'] = value),
      ];
      
      await Future.wait(futures);
      
      if (mounted) {
        setState(() {
          _runtimeStatus = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('检查运行时状态出错: $e');
      if (mounted) {
        setState(() {
          _runtimeStatus = {
            'Python': false,
            'Node.js': false,
            'Git': false,
            'UV': false,
          };
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            _buildSystemInfoRow('可执行文件路径', _getSafeExecutablePath()),
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
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
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
        if (_isLoading)
          const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          Wrap(
            spacing: 8.0,
            children: _runtimeStatus?.entries
                .map((entry) => _buildStatusChip(entry.key, entry.value))
                .toList() ?? [],
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
    try {
      final environment = Platform.environment;
      final arch = environment['PROCESSOR_ARCHITECTURE'] ?? 
                   environment['HOSTTYPE'] ?? 
                   'Unknown';
      return arch;
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getSafeExecutablePath() {
    try {
      return Platform.resolvedExecutable;
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<bool> _checkPythonAvailableAsync() async {
    try {
      final result = await Process.run('python', ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      try {
        final result = await Process.run('python3', ['--version']);
        return result.exitCode == 0;
      } catch (e) {
        return false;
      }
    }
  }

  Future<bool> _checkNodeAvailableAsync() async {
    try {
      final result = await Process.run('node', ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkGitAvailableAsync() async {
    try {
      final result = await Process.run('git', ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkUvAvailableAsync() async {
    try {
      final result = await Process.run('uv', ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }
} 