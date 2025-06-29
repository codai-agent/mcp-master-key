# MCP Hub 跨平台命令对比文档

## 概述

本文档详细记录了 MCP Hub 在不同平台（Windows 和 macOS/Linux）下处理 Node.js 包和 Python 包的命令差异。这些差异是为了解决各平台特有的环境问题和兼容性要求。

---

## Node.js 包处理

### 安装命令

#### Windows 平台
```bash
# 全局安装包
npm install -g --no-package-lock <package-name>

# 本地安装包（用于直接执行）
npm install --save <package-name> @modelcontextprotocol/sdk
```

#### macOS/Linux 平台
```bash
# 全局安装包
npm install -g <package-name>

# 检查包是否已安装
# 通过检查目录是否存在：{nodeBasePath}/lib/node_modules/{packageName}
```

### 运行命令

#### Windows 平台
**策略：直接使用 Node.js 执行包的入口文件**

```bash
# 可执行文件
node

# 参数
{packageDir}/build/index.js

# 完整命令示例
node /path/to/node_modules/@wopal/mcp-server-hotnews/build/index.js
```

**特点：**
- 使用直接文件路径执行
- 避免了 Windows 上的路径和权限问题
- 需要确保包在本地目录也安装了

#### macOS/Linux 平台
**策略：使用 Node.js spawn 方式，增强 PATH 设置**

```bash
# 可执行文件
node

# 参数（JavaScript 代码）
-e "
process.chdir('/working/directory');
process.env.PATH = '/working/directory/bin:' + (process.env.PATH || '');
require('child_process').spawn('mcp-server-hotnews', process.argv.slice(1), {stdio: 'inherit'});
"

# 完整命令示例
node -e "process.chdir('/path/to/runtime'); process.env.PATH = '/path/to/bin:' + (process.env.PATH || ''); require('child_process').spawn('mcp-server-hotnews', process.argv.slice(1), {stdio: 'inherit'});"
```

**特点：**
- 使用 npm 生态系统的标准做法
- 动态设置工作目录和 PATH
- 通过软链接执行包的可执行文件

---

## Python 包处理

### 安装命令

#### Windows 平台
```bash
# 使用 UV 工具安装
uv tool install <package-name>

# 环境变量设置
UV_CACHE_DIR={mcpHubPath}/cache/uv
UV_TOOL_DIR={mcpHubPath}/packages/uv/tools
UV_INDEX_URL=https://pypi.org/simple
```

#### macOS/Linux 平台
```bash
# 使用 UV 工具安装（相同）
uv tool install <package-name>

# 环境变量设置（相同）
UV_CACHE_DIR={mcpHubPath}/cache/uv
UV_TOOL_DIR={mcpHubPath}/packages/uv/tools
UV_INDEX_URL=https://pypi.org/simple
```

### 运行命令

#### Windows 平台
**策略：直接使用 UVX 执行**

```bash
# 可执行文件
uvx

# 参数
mcp-server-time --local-timezone America/New_York

# 完整命令示例
uvx mcp-server-time --local-timezone America/New_York
```

**特点：**
- 直接使用 UVX 命令
- 依赖 Windows 系统的 PATH 环境变量

#### macOS/Linux 平台
**策略：使用 Shell 包装器确保 PATH 正确传递**

```bash
# 可执行文件
/bin/sh

# 参数
-c 'export PATH="/bin:/usr/bin:$PATH" && "/path/to/uvx" mcp-server-time --local-timezone America/New_York'

# 完整命令示例
/bin/sh -c 'export PATH="/bin:/usr/bin:$PATH" && "/Users/user/.mcphub/runtimes/python/macos/arm64/uv-0.7.13/uvx" mcp-server-time --local-timezone America/New_York'
```

**特点：**
- 使用 shell 包装器
- 显式设置系统工具路径（/bin, /usr/bin）
- 解决 UV 生成脚本中 `realpath` 和 `dirname` 命令找不到的问题

---

## 环境变量配置

### Node.js 环境变量

#### Windows 平台
```bash
NODE_PATH={nodeBasePath}/node_modules
NPM_CONFIG_PREFIX={nodeBasePath}
NPM_CONFIG_CACHE={nodeBasePath}/npm-cache
NPM_CONFIG_REGISTRY=https://registry.npmjs.org/
```

#### macOS/Linux 平台
```bash
NODE_PATH={nodeBasePath}/lib/node_modules
NPM_CONFIG_PREFIX={nodeBasePath}
NPM_CONFIG_CACHE={nodeBasePath}/.npm
NPM_CONFIG_REGISTRY=https://registry.npmjs.org/
```

### Python 环境变量

#### 通用配置（所有平台）
```bash
UV_CACHE_DIR={mcpHubPath}/cache/uv
UV_DATA_DIR={mcpHubPath}/data/uv
UV_TOOL_DIR={mcpHubPath}/packages/uv/tools
UV_TOOL_BIN_DIR={mcpHubPath}/packages/uv/bin
UV_INDEX_URL=https://pypi.org/simple
UV_HTTP_TIMEOUT=120s
```

#### macOS/Linux 特殊配置
```bash
# 系统工具路径优先级设置
PATH="/bin:/usr/bin:{runtimePaths}:{userPaths}"

# 确保基础系统工具可用
# - realpath (用于 UV 脚本)
# - dirname (用于 UV 脚本)
# - python3 (Python 解释器)
```

---

## 关键差异总结

### 1. **Node.js 包执行方式**
- **Windows**: 直接执行包的 `build/index.js` 文件
- **macOS/Linux**: 使用 Node.js spawn 方式，通过软链接执行

### 2. **Python 包执行方式**
- **Windows**: 直接使用 `uvx` 命令
- **macOS/Linux**: 使用 shell 包装器，确保系统工具路径可用

### 3. **PATH 环境变量处理**
- **Windows**: 依赖系统默认 PATH 设置
- **macOS/Linux**: 主动设置系统工具路径（`/bin:/usr/bin`）到 PATH 最前面

### 4. **工作目录策略**
- **Windows**: 使用 Node.js 运行时目录作为工作目录
- **macOS/Linux**: 动态切换工作目录，确保软链接正确解析

---

## 实现原理

### Windows 平台选择直接执行的原因
1. **权限问题**: Windows 上的软链接支持有限
2. **路径问题**: Windows 路径中的空格和特殊字符处理复杂
3. **兼容性**: 直接文件执行更可靠

### macOS/Linux 平台使用 spawn 的原因
1. **生态兼容**: 符合 npm/UV 生态系统的标准做法
2. **软链接支持**: Unix 系统对软链接支持良好
3. **PATH 继承**: 更好的环境变量继承机制

### Shell 包装器的必要性（macOS/Linux）
UV 生成的 Python 脚本使用了复杂的 shebang 技巧：
```bash
#!/bin/sh
'''exec' "$(dirname -- "$(realpath -- "$0")")"/'python' "$0" "$@"
```

这个脚本需要 `realpath` 和 `dirname` 命令，但在 Flutter 启动的子进程中，这些系统工具可能不在 PATH 中。Shell 包装器通过显式设置 PATH 解决了这个问题。

---

## 维护建议

1. **保持平台隔离**: Windows 和 macOS/Linux 的逻辑应该完全分离，避免相互影响
2. **测试覆盖**: 每个平台的包安装和执行都需要独立测试
3. **错误处理**: 针对每个平台的特殊错误情况进行处理
4. **日志记录**: 详细记录每个平台使用的命令和参数，便于调试

---


1. Node.js 包处理差异
✅ Windows平台：
代码第637行：final args = [path.join(packageDir, 'build', 'index.js')];
代码第802行：['install', '-g', '--no-package-lock', packageName]
代码第719行：await _ensureLocalPackageInstalled(server.installSource!, workingDir);
✅ macOS/Linux平台：
代码第648-660行：JavaScript spawn代码，正好对应文档中的描述
代码第815行：['install', '-g', packageName] (无--no-package-lock)
2. Python 包处理差异
✅ Windows平台：
代码第702行：print(' ⚡ Using direct UVX execution with args: ${server.args.join(' ')}');
✅ macOS/Linux平台：
代码第689-696行：Shell包装器逻辑，完全对应文档描述
代码第691行：'export PATH="/bin:/usr/bin:\$PATH" && "$uvxPath" ${server.args.join(' ')}'
3. 环境变量配置
✅ Node.js环境变量差异：
代码第480-487行：Windows使用node_modules，Unix使用lib/node_modules
代码第484行：Windows使用npm-cache，Unix使用.npm
✅ Python环境变量：
代码第436-444行：UV相关环境变量设置，与文档一致
4. 可执行文件路径
✅ 平台差异：
代码第580-586行：Node.js在两个平台都使用相同可执行文件
代码第600-602行：macOS/Linux的UVX使用/bin/sh包装器
📋 总结
这份文档是我通过仔细阅读和分析当前代码实现后总结的，每一个命令、参数、环境变量设置都能在代码中找到对应的实现。文档不仅准确反映了当前的实现状态，还解释了为什么要这样实现的技术原理。
这确保了文档的：
准确性：与代码实现完全一致
实用性：可以作为开发和维护的参考
时效性：反映当前最新的代码状态

*文档版本: 1.0*  
*最后更新: 2025-06-29*  
*适用于: MCP Hub v1.0+* 