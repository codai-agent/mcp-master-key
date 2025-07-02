# MCP Hub 跨平台命令对比文档

## 概述

本文档详细记录了 MCP Hub 在不同平台（Windows 和 macOS/Linux）下处理 Node.js 包和 Python 包的命令差异。这些差异是为了解决各平台特有的环境问题和兼容性要求。

---

## Node.js 包处理

### 安装命令

#### Windows 平台
```bash
# 智能检查后安装（已修复：不再强制重装）
# 1. 检查包是否已安装（路径：{nodeBasePath}/node_modules/{packageName}）
# 2. 如果未安装，直接安装
npm install -g --no-package-lock <package-name>

# 本地安装包（用于直接执行）
npm install --save <package-name> @modelcontextprotocol/sdk
npm install --save-dev @modelcontextprotocol/sdk
```

#### macOS/Linux 平台
```bash
# 智能检查后安装
# 1. 检查包是否已安装（路径：{nodeBasePath}/lib/node_modules/{packageName}）
# 2. 如果未安装，直接安装
npm install -g <package-name>
```

**关键差异：**
- **路径结构**: Windows使用 `node_modules/`，Unix使用 `lib/node_modules/`
- **安装参数**: Windows使用 `--no-package-lock` 参数
- **智能检查**: 两个平台都使用智能检查，避免重复安装（已修复）

### 运行命令

#### Windows 平台
**策略：直接使用 Node.js 执行包的入口文件**

```bash
# 可执行文件
node

# 参数
{workingDir}/node_modules/{packageName}/build/index.js

# 完整命令示例
node /path/to/node_modules/@wopal/mcp-server-hotnews/build/index.js

# 前置条件：
# 1. 确保包已全局安装
# 2. 确保包在本地工作目录也安装了
# 3. 自动安装依赖：@modelcontextprotocol/sdk
```

**特点：**
- 使用直接文件路径执行
- 避免了 Windows 上的路径和权限问题
- 需要确保包在本地目录也安装了
- 自动处理 peer dependencies

#### macOS/Linux 平台
**策略：使用 Node.js spawn 方式，增强 PATH 设置**

```bash
# 可执行文件
node

# 参数（动态生成的JavaScript代码）
-e "
process.chdir('/working/directory');
process.env.PATH = '/working/directory/bin:' + (process.env.PATH || '');
require('child_process').spawn('executable-name', process.argv.slice(1), {stdio: 'inherit'});
"

# 完整命令示例
node -e "process.chdir('/path/to/runtime'); process.env.PATH = '/path/to/bin:' + (process.env.PATH || ''); require('child_process').spawn('mcp-server-hotnews', process.argv.slice(1), {stdio: 'inherit'});"
```

**特点：**
- 使用 npm 生态系统的标准做法
- 动态设置工作目录和 PATH
- 通过软链接执行包的可执行文件
- 从包名自动提取可执行文件名（处理scoped包）

---

## Python 包处理

### 安装命令

#### 通用安装（所有平台相同）
```bash
# UVX自动管理虚拟环境，无需预安装
# 包会在首次运行时自动下载和安装
uv tool install <package-name>

# 环境变量设置
UV_CACHE_DIR={mcpHubPath}/cache/uv
UV_DATA_DIR={mcpHubPath}/data/uv
UV_TOOL_DIR={mcpHubPath}/packages/uv/tools
UV_TOOL_BIN_DIR={mcpHubPath}/packages/uv/bin
UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple  # 国内镜像
UV_HTTP_TIMEOUT=180s  # 3分钟超时
UV_CONCURRENT_DOWNLOADS=2  # 降低并发数
UV_HTTP_RETRIES=3  # 重试3次
# 注意：不设置 UV_EXTRA_INDEX_URL 避免回退到官方源导致超时
```

**特点：**
- UVX自动管理虚拟环境
- 无需预安装，运行时自动下载
- 使用国内镜像源提高下载速度

### 运行命令

#### 智能执行策略（新增功能）
系统会优先检查是否有已安装的可执行文件：

1. **优先级1：直接可执行文件**
   - Windows: `{uvToolsDir}/{packageName}/Scripts/{packageName}.exe`
   - Unix: `{uvToolsDir}/{packageName}/bin/{packageName}`

2. **优先级2：Python模块执行**
   - 使用 `python -m {packageName}` 方式

3. **优先级3：UVX包装器**
   - 回退到标准UVX执行

#### Windows 平台
**策略：根据检测结果选择执行方式**

```bash
# 情况1：找到可执行文件
{uvToolsDir}/{packageName}/Scripts/{packageName}.exe --args

# 情况2：回退到Python模块
python -m {packageName} --args

# 情况3：标准UVX执行
uvx {packageName} --args
```

#### macOS/Linux 平台
**策略：使用 Shell 包装器确保 PATH 正确传递**

```bash
# 情况1：找到可执行文件
{uvToolsDir}/{packageName}/bin/{packageName} --args

# 情况2：回退到Python模块
python -m {packageName} --args

# 情况3：Shell包装器执行UVX
/bin/sh -c 'export PATH="/bin:/usr/bin:$PATH" && "/path/to/uvx" {packageName} --args'
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
NPM_CONFIG_REGISTRY=https://registry.npm.taobao.org/  # 国内镜像
USERPROFILE={homeDirectory}  # Windows特有
```

#### macOS/Linux 平台
```bash
NODE_PATH={nodeBasePath}/lib/node_modules
NPM_CONFIG_PREFIX={nodeBasePath}
NPM_CONFIG_CACHE={nodeBasePath}/.npm
NPM_CONFIG_REGISTRY=https://registry.npm.taobao.org/  # 国内镜像
HOME={homeDirectory}  # Unix特有
```

### Python 环境变量

#### 通用配置（所有平台）
```bash
UV_CACHE_DIR={mcpHubPath}/cache/uv
UV_DATA_DIR={mcpHubPath}/data/uv
UV_TOOL_DIR={mcpHubPath}/packages/uv/tools
UV_TOOL_BIN_DIR={mcpHubPath}/packages/uv/bin
UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
UV_HTTP_TIMEOUT=180  # 从120秒增加到180秒
UV_CONCURRENT_DOWNLOADS=2  # 从4降低到2
UV_HTTP_RETRIES=3  # 新增重试机制
# UV_EXTRA_INDEX_URL 已移除，避免回退到官方源
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

### 1. **Node.js 包安装方式**
- **Windows**: 智能检查后安装（已修复：不再强制重装）
- **macOS/Linux**: 智能检查后安装

### 2. **Node.js 包执行方式**
- **Windows**: 直接执行包的 `build/index.js` 文件 + 本地依赖安装
- **macOS/Linux**: 使用 Node.js spawn 方式，通过软链接执行

### 3. **Python 包执行方式**
- **新增智能检测**: 优先使用已安装的可执行文件
- **Windows**: 检查 `Scripts` 目录下的 `.exe` 文件
- **macOS/Linux**: 检查 `bin` 目录下的可执行文件 + shell包装器

### 4. **PATH 环境变量处理**
- **Windows**: 依赖系统默认 PATH 设置
- **macOS/Linux**: 主动设置系统工具路径（`/bin:/usr/bin`）到 PATH 最前面

### 5. **超时和重试机制**
- **UV_HTTP_TIMEOUT**: 从120秒增加到180秒
- **UV_CONCURRENT_DOWNLOADS**: 从4降低到2
- **新增 UV_HTTP_RETRIES**: 3次重试
- **移除 UV_EXTRA_INDEX_URL**: 避免回退到慢速官方源

---

## 实现原理

### Windows 平台选择直接执行的原因
1. **权限问题**: Windows 上的软链接支持有限
2. **路径问题**: Windows 路径中的空格和特殊字符处理复杂
3. **兼容性**: 直接文件执行更可靠
4. **依赖管理**: 自动处理本地依赖安装

### macOS/Linux 平台使用 spawn 的原因
1. **生态兼容**: 符合 npm/UV 生态系统的标准做法
2. **软链接支持**: Unix 系统对软链接支持良好
3. **PATH 继承**: 更好的环境变量继承机制
4. **动态路径**: 支持动态工作目录切换

### Shell 包装器的必要性（macOS/Linux）
UV 生成的 Python 脚本使用了复杂的 shebang 技巧：
```bash
#!/bin/sh
'''exec' "$(dirname -- "$(realpath -- "$0")")"/'python' "$0" "$@"
```

这个脚本需要 `realpath` 和 `dirname` 命令，但在 Flutter 启动的子进程中，这些系统工具可能不在 PATH 中。Shell 包装器通过显式设置 PATH 解决了这个问题。

### 智能执行检测的优势
1. **性能优化**: 避免重复下载已安装的包
2. **离线支持**: 可以在无网络环境下运行已安装的包
3. **稳定性**: 减少网络超时导致的启动失败
4. **跨平台兼容**: 自动适配不同平台的可执行文件结构

---

## 新增功能说明

### 1. **智能可执行文件检测**
- 自动检测 UVX tools 目录中的可执行文件
- 跨平台路径适配（Windows: Scripts/*.exe, Unix: bin/*）
- 优先使用已安装文件，避免重复下载

### 2. **网络超时优化**
- 增加 HTTP 超时时间到3分钟
- 降低并发下载数减少服务器压力
- 添加重试机制增强稳定性
- 移除官方源回退避免超时

### 3. **依赖管理改进**
- Windows 自动安装本地依赖
- 自动处理 peer dependencies
- 创建合适的 package.json 结构

---

## 维护建议

1. **保持平台隔离**: Windows 和 macOS/Linux 的逻辑应该完全分离，避免相互影响
2. **测试覆盖**: 每个平台的包安装和执行都需要独立测试
3. **错误处理**: 针对每个平台的特殊错误情况进行处理
4. **日志记录**: 详细记录每个平台使用的命令和参数，便于调试
5. **性能监控**: 监控可执行文件检测的性能影响
6. **网络配置**: 定期验证镜像源的可用性和速度

---

*文档版本: 2.0*  
*最后更新: 2025-01-03*  
*适用于: MCP Hub v1.0+*  
*新增: 智能执行检测、网络优化、依赖管理改进* 