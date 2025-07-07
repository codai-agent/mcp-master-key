[English](README.md) | [中文](README-zh.md)

<div align="center">
  <img src="https://github.com/user-attachments/assets/49a8b11b-0d2e-4b35-8c48-235140d9cd49" alt="MCP Hub Logo" width="200" height="200">

  # MCP Master Key

  **The Ultimate MCP Server Management Platform**

  *A cross-platform desktop application for managing Model Context Protocol (MCP) servers*

  ![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
  ![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)
  ![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
</div>

---

## ⚡  [**guidance document**](https://github.com/codai-agent/mcp-master-key/blob/main/guide-en.md) 

## ⚡ Quick Start

### **Option 1: Download Pre-built Release (Recommended)**
1. Visit the [Releases page](https://github.com/codai-agent/mcp-master-key/releases)
2. Download the appropriate package for your platform:
   - **Windows**: `mcphub-windows-x64.zip`
   - **macOS**: `mcphub-macos-arm64.dmg` (Apple Silicon) or `mcphub-macos-x64.dmg` (Intel)
   - **Linux**: `mcphub-linux-x64.tar.gz`
3. Install and run the application

### **Option 2: Build from Source**
1. **Clone the repository**:
   ```bash
   git clone https://github.com/codai-agent/mcp-master-key.git
   cd mcp-master-key
   ```

2. **Download platform runtimes**:
   - Go to the [Releases page](https://github.com/codai-agent/mcp-master-key/releases/tag/v0.0.1)
   - Download the platform-specific runtime files(runtimes-xxxx.zip):
     - `nodejs.zip` - Node.js runtime environment
     - `python.zip` - Python runtime environment
   - Place them in the `assets/runtimes/` directory:
     ```
     assets/
     └── runtimes/
         ├── nodejs.zip
         └── python.zip
     ```

3. **Build the application**:
   ```bash
   # For macOS
   flutter build macos --debug
   
   # For Windows
   flutter build windows --debug
   
   # For Linux
   flutter build linux --debug
   ```

4. **Run the application**:

   - The built application will be available in the `build/` directory
   - Navigate to the platform-specific build folder and run the executable

5. **MCP host/client（codai/cline/cursor/cherry sutido...）config**：

   - SSE：

   "mcphub": {

   ​      "autoApprove": [],

   ​      "disabled": false,

   ​      "timeout": 60,

   ​      "type": "sse",

   ​      "url": "http://127.0.0.1:3000/sse"

   ​    }

   - Streamable：

   "mcphub_streamable": {

   ​      "autoApprove": [],

   ​      "disabled": true,

   ​      "timeout": 60,

   ​      "type": "streamableHttp",

   ​      "url": "http://127.0.0.1:3001/mcp"

   ​    }

### **System Requirements**
- **Operating System**: Windows 10/11, macOS 10.14+, or Linux (Ubuntu 18.04+ recommended)
- **Memory**: 4GB RAM minimum, 8GB recommended
- **Storage**: 2GB available space
- **Network**: Internet connection for downloading MCP servers

---

## 🚀 Key Features
<img width="1200" alt="11" src="https://github.com/user-attachments/assets/8abd4f57-cc1f-4a97-9d7a-8cf03b9aec77" />

### **Unified Server Management**
- **One-Click Installation**: Install MCP servers from various sources (PyPI, NPM, GitHub, local files)
- **Intelligent Strategy Detection**: Automatically detects the best installation method (uvx, npx, pip, npm, git clone)
- **Cross-Platform Runtime**: Built-in isolated Python and Node.js environments for maximum compatibility across Windows, macOS, and Linux
- **Real-Time Monitoring**: Live server status tracking with detailed logs and performance metrics

### **Advanced Hub Architecture**
- **MCP Protocol Compliance**: Full implementation of the Model Context Protocol specification
- **Multi-Client Support**: Supports both single-client (SSE) and multi-client (Streamable) connection modes
- **Tool Aggregation**: Seamlessly combines tools from multiple MCP servers into a unified interface
- **Session Isolation**: Secure isolation between different client connections

### **Developer-Friendly Experience**
- **Configuration Management**: Visual JSON editor with syntax validation and auto-completion
- **Comprehensive Logging**: Detailed installation, runtime, and error logs for debugging
- **Market Integration**: Browse and install servers from the MCP ecosystem marketplace
- **Auto-Recovery**: Intelligent server state persistence and automatic restart capabilities

### **Enterprise-Ready Features**
- **Download Acceleration**: Configurable mirror sources for faster package downloads in different regions
- **Storage Management**: Efficient cache and dependency management with cleanup tools
- **Internationalization**: Full support for English and Chinese interfaces
- **Theme Customization**: Light and dark themes with system preference detection

---

## 🌟 Why MCP Hub Matters

### **Bridging the AI Ecosystem Gap**
In the rapidly evolving AI landscape, the **Model Context Protocol (MCP)** represents a critical standardization effort for AI tool integration. MCP Hub serves as the essential infrastructure that makes MCP adoption practical and scalable for developers, organizations, and AI enthusiasts.

### **Solving Real-World Integration Challenges**
- **Complexity Reduction**: Eliminates the technical barriers of managing multiple MCP servers manually
- **Reliability Assurance**: Provides robust error handling and automatic recovery mechanisms
- **Performance Optimization**: Optimizes resource usage through intelligent process management and caching
- **Security Enhancement**: Implements proper isolation and sandboxing for safe server execution

### **Accelerating AI Development**
MCP Hub transforms how developers interact with AI tools by:
- **Democratizing Access**: Makes advanced MCP server capabilities accessible to non-technical users
- **Standardizing Workflows**: Establishes consistent patterns for MCP server deployment and management
- **Enabling Innovation**: Provides a stable foundation for building sophisticated AI applications
- **Fostering Community**: Creates a unified platform for sharing and discovering MCP tools

### **Future-Proofing AI Infrastructure**
As the MCP ecosystem continues to grow, MCP Hub positions itself as the **de facto standard** for MCP server management, ensuring that users can seamlessly adopt new tools and technologies as they emerge.

---

## 📄 License

```
Copyright (c) 2024 Codai Studio

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

### **Publisher Information**
- **Publisher**: Codai Studio
- **License**: Apache License 2.0
- **Open Source**: This project is open source and welcomes community contributions
- **Support**: For technical support and feature requests, please visit our GitHub repository

---

<div align="center">
  <p><strong>MCP Master Key - Empowering the Future of AI Tool Integration</strong></p>
  <p><em>Built with ❤️ by Codai Studio</em></p>
</div>
