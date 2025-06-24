# MCP Hub Streamable模式客户端配置指南

## 🎯 问题诊断结果

通过curl测试和代码分析，我们发现了以下情况：

### ✅ 服务器状态
- **Streamable MCP Hub** 已成功启动在端口3001
- **子服务器** (mcp-server-hotnews) 已连接并运行
- **工具注册** 正常，Hub显示有2个工具可用

### ❌ 连接问题
客户端连接 `http://127.0.0.1:3001/mcp` 时遇到错误：
```
SSE error: Non-200 status code (400)
Parse error: type 'Null' is not a subtype of type 'Map<String, dynamic>' in type cast
```

## 🔧 客户端配置修正

### 原配置（SSE模式）：
```json
"mcphub": {
  "autoApprove": [],
  "disabled": true,
  "timeout": 60,
  "url": "http://127.0.0.1:3000/sse",
  "transportType": "sse"
}
```

### 修正后配置（Streamable模式）：
```json
"mcphub": {
  "autoApprove": [],
  "disabled": false,
  "timeout": 60,
  "url": "http://127.0.0.1:3001/mcp",
  "transportType": "streamable"
}
```

**关键变更：**
1. **端口**：`3000` → `3001`
2. **路径**：`/sse` → `/mcp`
3. **传输类型**：`"sse"` → `"streamable"`
4. **启用服务**：`"disabled": true` → `"disabled": false`

## 🚨 重要发现

经过测试，我们发现即使是官方的 `server_streamable_https.dart` 示例也出现了同样的解析错误。这表明问题可能在于：

### 可能的原因：

1. **MCP客户端兼容性**
   - 您使用的MCP客户端可能不完全支持Streamable协议
   - 需要确认客户端版本是否与mcp_dart 0.5.2兼容

2. **协议版本不匹配**
   - Streamable模式可能需要特定的协议版本
   - 建议检查客户端支持的协议版本

3. **头部要求**
   - Streamable模式需要特定的HTTP头部
   - 客户端可能没有发送正确的Accept头部

## 🛠️ 建议的解决方案

### 方案一：继续使用SSE模式（推荐）
如果多客户端需求不是很迫切，建议暂时继续使用SSE模式：

```json
"mcphub": {
  "autoApprove": [],
  "disabled": false,
  "timeout": 60,
  "url": "http://127.0.0.1:3000/sse",
  "transportType": "sse"
}
```

**优势：**
- ✅ 已验证稳定工作
- ✅ 与现有客户端完全兼容
- ✅ 性能良好，适合大多数使用场景

### 方案二：客户端升级
确认您使用的MCP客户端版本，并尝试：

1. **更新客户端到最新版本**
2. **检查客户端文档**，看是否支持Streamable协议
3. **联系客户端开发者**，确认Streamable支持情况

### 方案三：协议调试
如果需要继续调试Streamable模式：

1. **检查客户端日志**，看具体的错误信息
2. **尝试不同的transportType值**：
   - `"streamable"`
   - `"http"`
   - `"http-sse"`

## 📋 当前状态总结

- ✅ **UI黑屏问题** 已解决
- ✅ **SSE模式** 工作正常
- ✅ **Streamable服务器** 启动成功
- ❌ **Streamable客户端连接** 需要进一步调试
- ✅ **子服务器管理** 正常工作

## 🎯 建议下一步

1. **优先使用SSE模式**保证当前功能正常
2. **如果确实需要多客户端支持**，再继续调试Streamable模式
3. **检查客户端文档**，确认Streamable协议支持

您觉得哪种方案更符合当前需求？ 