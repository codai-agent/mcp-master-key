import 'dart:io';

Future<void> main() async {
  print('🧪 Testing Internal Runtime Discovery');
  
  try {
    // 模拟RuntimeManager的路径构建逻辑
    final homePath = Platform.environment['HOME'] ?? '';
    final basePath = '$homePath/Library/Application Support/com.codai.mcphub.mcphub/mcp_hub/assets/runtimes';
    
    print('📁 Expected runtime base path: $basePath');
    
    // 检查是否存在runtime目录
    final runtimeDir = Directory(basePath);
    if (!await runtimeDir.exists()) {
      print('❌ Runtime directory not found: $basePath');
      print('   This may be because the app hasn\'t been run yet or runtime extraction failed');
      return;
    }
    
    print('✅ Runtime directory exists');
    
    // 构建预期的NPX路径
    final platform = Platform.operatingSystem;
    String arch;
    if (Platform.isMacOS) {
      final result = await Process.run('uname', ['-m']);
      arch = result.stdout.toString().trim() == 'arm64' ? 'arm64' : 'x64';
    } else {
      arch = 'x64';
    }
    
    final nodeVersion = '20.10.0';
    final expectedNpxPath = '$basePath/nodejs/$platform/$arch/node-v$nodeVersion/bin/npx';
    
    print('🔍 Expected NPX path: $expectedNpxPath');
    
    final npxFile = File(expectedNpxPath);
    if (await npxFile.exists()) {
      print('✅ Internal NPX executable found!');
      
      // 测试执行
      try {
        final result = await Process.run(expectedNpxPath, ['--version']);
        print('   📋 NPX version: ${result.stdout.toString().trim()}');
        print('   ✅ Internal NPX is functional');
      } catch (e) {
        print('   ⚠️ NPX executable exists but failed to run: $e');
      }
    } else {
      print('❌ Internal NPX executable not found');
    }
    
    // 列出实际的runtime目录结构
    print('\n📂 Actual runtime directory contents:');
    await _listDirectoryRecursive(runtimeDir, 0, 3);
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}

Future<void> _listDirectoryRecursive(Directory dir, int depth, int maxDepth) async {
  if (depth > maxDepth) return;
  
  try {
    final entities = await dir.list().toList();
    entities.sort((a, b) => a.path.compareTo(b.path));
    
    for (final entity in entities) {
      final indent = '  ' * depth;
      final name = entity.path.split('/').last;
      
      if (entity is Directory) {
        print('$indent📁 $name/');
        if (depth < maxDepth) {
          await _listDirectoryRecursive(entity, depth + 1, maxDepth);
        }
      } else {
        final stat = await entity.stat();
        final size = stat.size;
        final sizeStr = size > 1024 * 1024 
            ? '${(size / (1024 * 1024)).toStringAsFixed(1)}MB'
            : size > 1024 
                ? '${(size / 1024).toStringAsFixed(1)}KB'
                : '${size}B';
        print('$indent📄 $name ($sizeStr)');
      }
    }
  } catch (e) {
    print('Error listing directory ${dir.path}: $e');
  }
} 