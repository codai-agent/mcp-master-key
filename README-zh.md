[English](README.md) | [中文](README-zh.md)

<div align="center">
  <img src="https://github.com/user-attachments/assets/49a8b11b-0d2e-4b35-8c48-235140d9cd49" alt="MCP Hub Logo" width="200" height="200">

  # MCP 管家

  **终极MCP服务器管理平台**

  *用于管理模型上下文协议(MCP)服务器的跨平台桌面应用程序*

  ![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
  ![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)
  ![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
</div>

---

## ⚡  [**使用指南**](https://github.com/codai-agent/mcp-master-key/blob/main/guide-zh.md) 

## ⚡ 快速开始

### **方式一：下载预构建版本（推荐）**
1. 访问 [Releases页面](https://github.com/codai-agent/mcp-master-key/releases)
2. 下载适合您平台的安装包：
   - **Windows**: `mcphub-windows-x64.zip`
   - **macOS**: `mcphub-macos-arm64.dmg` (Apple Silicon) 或 `mcphub-macos-x64.dmg` (Intel)
   - **Linux**: `mcphub-linux-x64.tar.gz`
3. 安装并运行应用程序

### **方式二：从源码构建**
1. **克隆仓库**：
   ```bash
   git clone https://github.com/codai-agent/mcp-master-key.git
   cd mcp-master-key
   ```

2. **下载平台运行时**：
   - 前往 [Releases页面](https://github.com/codai-agent/mcp-master-key/releases/tag/v0.0.1)
   - 下载平台对应的运行时文件(runtimes-xxxx.zip)：
     - `nodejs.zip` - Node.js运行时环境
     - `python.zip` - Python运行时环境
   - 将它们放置到 `assets/runtimes/` 目录中：
     ```
     assets/
     └── runtimes/
         ├── nodejs.zip
         └── python.zip
     ```

3. **构建应用程序**：
   ```bash
   # macOS平台
   flutter build macos --debug
   
   # Windows平台
   flutter build windows --debug
   
   # Linux平台
   flutter build linux --debug
   ```

4. **运行应用程序**：
   - 构建完成的应用程序将位于 `build/` 目录中
   - 导航到对应平台的构建文件夹并运行可执行文件

5. MCP客户端（codai/cline/cursor/cherry sutido等）的配置：

   1. SSE：

      "mcphub": {

      ​      "autoApprove": [],

      ​      "disabled": false,

      ​      "timeout": 60,

      ​      "type": "sse",

      ​      "url": "http://127.0.0.1:3000/sse"

      ​    }

   2. Streamable：

      "mcphub_streamable": {

      ​      "autoApprove": [],

      ​      "disabled": true,

      ​      "timeout": 60,

      ​      "type": "streamableHttp",

      ​      "url": "http://127.0.0.1:3001/mcp"

      ​    }


### **系统要求**
- **操作系统**: Windows 10/11、macOS 10.14+ 或 Linux (推荐 Ubuntu 18.04+)
- **内存**: 最低 4GB RAM，推荐 8GB
- **存储空间**: 2GB 可用空间
- **网络**: 需要互联网连接以下载 MCP 服务器

---

## 🚀 核心功能
<img width="1200" alt="ui" src="https://github.com/user-attachments/assets/1ec55933-ed7a-44cc-b3d7-77cd8e880e3c" />


### **统一服务器管理**
- **一键安装**: 支持从多种来源安装MCP服务器(PyPI、NPM、GitHub、本地文件)
- **智能策略检测**: 自动检测最佳安装方法(uvx、npx、pip、npm、git clone)
- **跨平台运行时**: 内置隔离的Python和Node.js环境，确保在Windows、macOS和Linux上的最大兼容性
- **实时监控**: 实时服务器状态跟踪，提供详细日志和性能指标

### **先进的Hub架构**
- **MCP协议合规**: 完整实现模型上下文协议规范
- **多客户端支持**: 支持单客户端(SSE)和多客户端(Streamable)连接模式
- **工具聚合**: 无缝整合多个MCP服务器的工具到统一界面
- **会话隔离**: 不同客户端连接间的安全隔离

### **开发者友好体验**
- **配置管理**: 可视化JSON编辑器，支持语法验证和自动补全
- **全面日志**: 详细的安装、运行时和错误日志，便于调试
- **市场集成**: 浏览和安装MCP生态系统市场中的服务器
- **自动恢复**: 智能服务器状态持久化和自动重启功能

### **企业级特性**
- **下载加速**: 可配置镜像源，在不同地区实现更快的包下载速度
- **存储管理**: 高效的缓存和依赖管理，提供清理工具
- **国际化**: 完整支持中英文界面
- **主题定制**: 明暗主题切换，支持系统偏好检测

---

## 🌟 MCP Hub的重要意义

### **连接AI生态系统的桥梁**
在快速发展的AI领域中，**模型上下文协议(MCP)**代表了AI工具集成标准化的关键努力。MCP Hub作为基础设施，使MCP的采用对开发者、组织和AI爱好者来说变得实用且可扩展。

### **解决真实世界的集成挑战**
- **复杂性降低**: 消除手动管理多个MCP服务器的技术障碍
- **可靠性保证**: 提供强大的错误处理和自动恢复机制
- **性能优化**: 通过智能进程管理和缓存优化资源使用
- **安全增强**: 为安全的服务器执行实现适当的隔离和沙箱

### **加速AI开发**
MCP Hub通过以下方式改变开发者与AI工具的交互：
- **普及访问**: 使非技术用户也能访问高级MCP服务器功能
- **标准化工作流**: 为MCP服务器部署和管理建立一致的模式
- **促进创新**: 为构建复杂AI应用程序提供稳定的基础
- **培育社区**: 创建统一平台用于分享和发现MCP工具

### **面向未来的AI基础设施**
随着MCP生态系统的持续增长，MCP Hub将自己定位为MCP服务器管理的**事实标准**，确保用户能够无缝采用新出现的工具和技术。

---

## 📄 许可证

```
版权所有 (c) 2024 Codai Studio

根据Apache许可证2.0版("许可证")获得许可；
除非符合许可证，否则您不得使用此文件。
您可以在以下位置获得许可证副本：

    http://www.apache.org/licenses/LICENSE-2.0

除非适用法律要求或书面同意，否则根据许可证分发的软件
按"原样"分发，不提供任何明示或暗示的保证或条件。
请参阅许可证以了解许可证下的特定语言管理权限和
限制。
```

### **发行方信息**
- **发行方**: Codai Studio
- **许可证**: Apache License 2.0
- **开源**: 本项目为开源项目，欢迎社区贡献
- **支持**: 如需技术支持和功能请求，请访问我们的GitHub仓库

---

<div align="center">
  <p><strong>MCP 管家 - 赋能AI工具集成的未来</strong></p>
  <p><em>由Codai Studio用❤️构建</em></p>
</div> 
