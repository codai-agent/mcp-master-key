# MCP Hub 开发 TODO 清单

## 项目总览
- [ ] 初始化Flutter项目
- [ ] 配置跨平台桌面支持（Windows/Linux/macOS）
- [ ] 设置项目基础架构和依赖包

---

## 📋 **第一阶段：基础架构搭建**

### 1.1 项目初始化
- [ ] 创建Flutter桌面项目
- [ ] 配置`pubspec.yaml`依赖包
  - [ ] 添加MCP协议支持：`mcp_dart: ^1.0.0`
  - [ ] 添加进程管理：`process_run: ^0.12.0`
  - [ ] 添加HTTP服务器：`shelf: ^1.4.0`, `shelf_router: ^1.1.0`
  - [ ] 添加状态管理：`riverpod: ^2.0.0`
  - [ ] 添加桌面功能：`window_manager: ^0.3.0`, `tray_manager: ^0.2.0`
  - [ ] 添加数据库：`sqflite_common_ffi: ^2.3.0`
  - [ ] 添加文件操作：`path_provider: ^2.0.0`, `path: ^1.8.0`
  - [ ] 添加网络请求：`dio: ^5.0.0`
  - [ ] 添加归档解压：`archive: ^3.4.0`
  - [ ] 添加Git操作：`git: ^2.2.0`
  - [ ] 添加YAML解析：`yaml: ^3.1.0`
  - [ ] 添加JSON支持：`json_annotation: ^4.8.0`
  - [ ] 添加日志：`logger: ^2.0.0`
- [ ] 配置开发依赖包（build_runner, json_serializable等）
- [ ] 设置应用图标和启动配置

### 1.2 目录结构设计
```
lib/
├── main.dart
├── core/                    # 核心模块
│   ├── constants/           # 常量定义
│   ├── utils/              # 工具类
│   ├── exceptions/         # 异常定义
│   └── services/           # 核心服务
├── data/                   # 数据层
│   ├── models/             # 数据模型
│   ├── repositories/       # 数据仓库
│   ├── datasources/        # 数据源
│   └── database/           # 数据库相关
├── domain/                 # 业务逻辑层
│   ├── entities/           # 实体类
│   ├── usecases/          # 用例
│   └── repositories/       # 仓库接口
├── presentation/           # 表示层
│   ├── pages/             # 页面
│   ├── widgets/           # 组件
│   ├── providers/         # 状态管理
│   └── themes/            # 主题样式
└── infrastructure/         # 基础设施层
    ├── runtime/           # 运行时管理
    ├── mcp/              # MCP协议实现
    ├── github/           # GitHub集成
    └── environment/      # 环境管理
```

- [x] 创建完整的目录结构
- [ ] 设置barrel文件导出

### 1.3 核心常量和配置
- [ ] 定义应用常量（`lib/core/constants/app_constants.dart`）
  - [ ] Python版本：3.12.6
  - [ ] UV版本：0.4.18  
  - [ ] Node.js版本：20.10.0
  - [ ] 数据库版本：1
  - [ ] 应用版本信息
- [ ] 定义路径常量（`lib/core/constants/path_constants.dart`）
- [ ] 定义MCP协议常量（`lib/core/constants/mcp_constants.dart`）

---

## 📋 **第二阶段：数据库设计与实现**

### 2.1 数据库架构
- [x] 实现数据库管理器（`lib/infrastructure/database/database_service.dart`）
  - [x] SQLite数据库初始化
  - [x] 数据库连接管理
  - [x] 数据库关闭和清理
- [ ] 创建数据库表结构（`lib/data/database/database_schema.dart`）
  - [ ] `mcp_servers` 表创建脚本
  - [ ] `server_lifecycle_events` 表创建脚本  
  - [ ] `server_runtime_stats` 表创建脚本
  - [ ] `server_logs` 表创建脚本
  - [ ] `mcp_requests` 表创建脚本
  - [ ] `system_events` 表创建脚本
- [ ] 创建数据库索引（`lib/data/database/database_indexes.dart`）
  - [ ] 生命周期事件查询索引
  - [ ] 运行时统计查询索引
  - [ ] 日志查询索引
  - [ ] 请求追踪索引

### 2.2 数据模型定义
- [x] MCP服务器模型（`lib/core/models/mcp_server.dart`）
  - [x] 基本信息字段
  - [x] JSON序列化/反序列化
  - [x] 数据验证
- [ ] 生命周期事件模型（`lib/data/models/lifecycle_event_model.dart`）
  - [ ] 事件类型枚举
  - [ ] 事件状态枚举
  - [ ] 事件数据模型
- [ ] 运行时统计模型（`lib/data/models/runtime_stats_model.dart`）
- [ ] 日志模型（`lib/data/models/log_model.dart`）
- [ ] MCP请求模型（`lib/data/models/mcp_request_model.dart`）
- [ ] 系统事件模型（`lib/data/models/system_event_model.dart`）

### 2.3 数据访问层实现
- [ ] 服务器生命周期服务（`lib/data/services/server_lifecycle_service.dart`）
  - [ ] 记录生命周期事件
  - [ ] 开始/结束会话
  - [ ] 更新运行时统计
  - [ ] 记录心跳
  - [ ] 查询生命周期事件
  - [ ] 获取运行时统计
  - [ ] 获取服务器健康状态
- [ ] 日志服务（`lib/data/services/log_service.dart`）
  - [ ] 写入日志
  - [ ] 批量写入日志
  - [ ] 查询日志
  - [ ] 清理旧日志
  - [ ] 导出日志
- [ ] 请求追踪服务（`lib/data/services/request_tracking_service.dart`）
  - [ ] 记录请求开始
  - [ ] 记录请求完成
  - [ ] 获取请求统计
  - [ ] 获取慢请求
- [ ] 数据库维护服务（`lib/data/services/database_maintenance_service.dart`）
  - [ ] 定期清理任务
  - [ ] 清理旧日志
  - [ ] 清理旧事件
  - [ ] 数据库优化
  - [ ] 更新统计信息

### 2.4 数据库迁移
- [ ] 数据库迁移管理（`lib/data/database/database_migration.dart`）
  - [ ] 版本管理
  - [ ] 迁移脚本执行
  - [ ] 初始表创建

---

## 📋 **第三阶段：运行时环境管理**

### 3.1 平台检测和架构识别
- [x] 平台信息管理（`lib/infrastructure/runtime/platform_info.dart`）
  - [x] 操作系统检测
  - [x] CPU架构检测（x64/ARM64）
  - [x] 平台信息封装

### 3.2 运行时管理器
- [x] 运行时管理器核心（`lib/infrastructure/runtime/runtime_manager.dart`）
  - [x] 平台信息获取
  - [x] Python可执行文件路径解析
  - [x] UV可执行文件路径解析
  - [x] Node.js可执行文件路径解析
  - [x] NPX可执行文件路径解析
  - [x] 运行时基础路径管理
- [x] 运行时初始化（`lib/infrastructure/runtime/runtime_initializer.dart`）
  - [x] 运行时资源提取
  - [x] Python环境设置
  - [x] Node.js环境设置
  - [x] 运行时验证

### 3.3 资源管理
- [x] 资源提取器（`lib/infrastructure/runtime/asset_extractor.dart`）
  - [x] 从assets提取运行时文件
  - [x] 文件权限设置
  - [x] 解压缩处理
- [ ] 运行时验证器（`lib/infrastructure/runtime/runtime_validator.dart`）
  - [ ] Python环境验证
  - [ ] UV工具验证
  - [ ] Node.js环境验证
  - [ ] NPX工具验证

---

## 📋 **第四阶段：隔离环境管理**

### 4.1 环境管理核心
- [ ] 隔离环境管理器（`lib/infrastructure/environment/isolated_environment_manager.dart`）
  - [ ] 环境创建
  - [ ] 环境删除
  - [ ] 环境列表
  - [ ] 环境信息获取
- [ ] Python环境管理（`lib/infrastructure/environment/python_environment.dart`）
  - [ ] Python虚拟环境创建
  - [ ] 依赖包安装
  - [ ] 环境激活
  - [ ] 包列表管理
- [ ] Node.js环境管理（`lib/infrastructure/environment/node_environment.dart`）
  - [ ] Node.js项目环境创建
  - [ ] NPM包安装
  - [ ] package.json管理
  - [ ] node_modules管理

### 4.2 包安装管理
- [ ] 包安装器（`lib/infrastructure/environment/package_installer.dart`）
  - [ ] Python包安装
  - [ ] Node.js包安装
  - [ ] 安装结果处理
  - [ ] 安装日志记录
- [ ] 环境运行器（`lib/infrastructure/environment/environment_runner.dart`）
  - [ ] 在环境中运行命令
  - [ ] 环境变量设置
  - [ ] 进程管理

---

## 📋 **第五阶段：MCP配置解析与安装策略**

### 5.1 MCP配置解析核心
- [ ] MCP配置分析器（`lib/infrastructure/mcp/mcp_config_analyzer.dart`）
  - [ ] 配置JSON解析和验证
  - [ ] 服务器配置分析
  - [ ] 安装策略确定
  - [ ] 命令类型检测
- [ ] 安装策略基类（`lib/infrastructure/mcp/install_strategies/server_install_strategy.dart`）
  - [ ] 抽象策略接口定义
  - [ ] 执行命令生成接口
  - [ ] 安装和验证接口
  - [ ] 公共方法实现

### 5.2 具体安装策略实现
- [ ] 自包含命令策略（`lib/infrastructure/mcp/install_strategies/self_contained_strategy.dart`）
  - [ ] npx -y 命令处理
  - [ ] uvx 命令处理
  - [ ] Windows cmd包装处理
  - [ ] 执行命令生成
  - [ ] 验证逻辑实现
- [ ] 预安装命令策略（`lib/infrastructure/mcp/install_strategies/pre_installed_strategy.dart`）
  - [ ] Python/Node运行时命令处理
  - [ ] 安装源配置管理
  - [ ] Python包安装逻辑
  - [ ] Node包安装逻辑
  - [ ] 安装验证
- [ ] 本地路径策略（`lib/infrastructure/mcp/install_strategies/local_path_strategy.dart`）
  - [ ] 绝对路径检测
  - [ ] 相对路径处理
  - [ ] 路径转换逻辑
  - [ ] 文件存在验证
- [ ] 未知策略（`lib/infrastructure/mcp/install_strategies/unknown_strategy.dart`）
  - [ ] 错误处理
  - [ ] 用户提示信息
  - [ ] 手动配置引导

### 5.3 配置数据模型
- [ ] 安装策略模型（`lib/infrastructure/mcp/models/install_strategy.dart`）
- [ ] 执行命令模型（`lib/infrastructure/mcp/models/execution_command.dart`）
- [ ] 安装结果模型（`lib/infrastructure/mcp/models/install_result.dart`）
- [ ] MCP服务器配置模型（`lib/data/models/mcp_server_config_model.dart`）
  - [ ] 原始配置存储
  - [ ] 解析后配置
  - [ ] 配置验证规则

## 📋 **第六阶段：GitHub源码安装解析**

### 6.1 GitHub集成
- [ ] GitHub仓库分析器（`lib/infrastructure/github/github_source_analyzer.dart`）
  - [ ] GitHub URL解析
  - [ ] 仓库内容获取
  - [ ] 项目类型检测
  - [ ] 安装方式检测
- [ ] 仓库内容获取（`lib/infrastructure/github/repository_content_fetcher.dart`）
  - [ ] GitHub API调用
  - [ ] 文件内容获取
  - [ ] 目录结构分析

### 6.2 项目分析
- [ ] Python项目分析器（`lib/infrastructure/github/python_project_analyzer.dart`）
  - [ ] pyproject.toml解析
  - [ ] setup.py解析
  - [ ] requirements.txt处理
  - [ ] Poetry项目检测
  - [ ] 安装命令生成
- [ ] Node.js项目分析器（`lib/infrastructure/github/node_project_analyzer.dart`）
  - [ ] package.json解析
  - [ ] 包管理器检测（yarn/pnpm/npm）
  - [ ] 构建脚本检测
  - [ ] 安装命令生成

### 6.3 源码安装执行
- [ ] 源码安装器（`lib/infrastructure/github/source_installer.dart`）
  - [ ] Git仓库克隆
  - [ ] 预安装命令执行
  - [ ] 主安装命令执行
  - [ ] 后安装清理
  - [ ] 安装过程日志记录

---

## 📋 **第七阶段：MCP协议实现**

### 7.1 MCP服务器端实现
- [x] MCP Hub服务器（`lib/infrastructure/mcp/mcp_hub_server.dart`）
  - [x] MCP协议服务器实现
  - [x] 客户端连接管理
  - [x] 消息路由
  - [x] 错误处理
- [ ] MCP消息处理器（`lib/infrastructure/mcp/mcp_message_handler.dart`）
  - [ ] 消息解析
  - [ ] 消息分发
  - [ ] 响应生成

### 7.2 MCP客户端实现
- [x] MCP客户端管理器（`lib/core/protocols/mcp_client.dart`）
  - [x] 子服务器连接管理
  - [x] STDIO通信
  - [x] SSE通信
  - [x] 连接池管理
- [ ] 消息中转器（`lib/infrastructure/mcp/message_relay.dart`）
  - [ ] 消息转发
  - [ ] 请求追踪
  - [ ] 响应路由
  - [ ] 超时处理

### 7.3 MCP协议数据模型
- [x] MCP消息模型（`lib/core/protocols/mcp_protocol.dart`）
- [x] MCP请求模型（`lib/core/protocols/mcp_protocol.dart`）
- [x] MCP响应模型（`lib/core/protocols/mcp_protocol.dart`）
- [x] MCP错误模型（`lib/core/protocols/mcp_protocol.dart`）

---

## 📋 **第八阶段：服务器管理**

### 8.1 服务器生命周期管理
- [x] 服务器管理器（`lib/business/managers/enhanced_mcp_process_manager.dart`）
  - [x] 服务器注册（基于MCP配置）
  - [x] 服务器启动（使用解析后的执行命令）
  - [x] 服务器停止
  - [x] 服务器重启
  - [x] 服务器卸载
  - [x] 服务器状态监控
- [x] 进程管理器（`lib/business/managers/mcp_process_manager.dart`）
  - [x] 进程启动（在隔离环境中）
  - [x] 进程监控
  - [x] 进程停止
  - [x] 进程重启
  - [x] 资源使用监控

### 8.2 配置管理
- [x] 配置管理器（`lib/business/parsers/mcp_config_parser.dart`）
  - [x] MCP服务器配置读取
  - [x] 原始配置与解析配置管理
  - [x] 配置验证
  - [x] 配置更新
  - [ ] 配置备份
- [x] 配置验证器（`lib/business/parsers/mcp_config_parser.dart`）
  - [x] MCP配置JSON验证
  - [x] 命令和参数验证
  - [x] 环境变量验证
  - [x] 依赖验证

---

## 📋 **第九阶段：用户界面实现**

### 9.1 主题和样式
- [ ] 应用主题（`lib/presentation/themes/app_theme.dart`）
  - [ ] 亮色主题
  - [ ] 暗色主题
  - [ ] 色彩方案
  - [ ] 字体设置
- [ ] 组件样式（`lib/presentation/themes/component_styles.dart`）
  - [ ] 按钮样式
  - [ ] 卡片样式
  - [ ] 列表样式
  - [ ] 表单样式

### 9.2 公共组件
- [x] 服务器卡片组件（`lib/presentation/widgets/server_card.dart`）
  - [x] 服务器信息展示
  - [x] 状态指示器
  - [x] 操作按钮
  - [x] 展开/折叠功能
- [ ] 状态指示器（`lib/presentation/widgets/status_indicator.dart`）
  - [ ] 运行状态显示
  - [ ] 动画效果
- [ ] 日志查看器（`lib/presentation/widgets/log_viewer.dart`）
  - [ ] 日志滚动显示
  - [ ] 日志筛选
  - [ ] 日志搜索
  - [ ] 日志导出
- [ ] 配置编辑器（`lib/presentation/widgets/config_editor.dart`）
  - [ ] JSON配置编辑
  - [ ] 语法高亮
  - [ ] 验证提示
- [ ] 配置分析结果组件（`lib/presentation/widgets/config_analysis_result.dart`）
  - [ ] 策略类型显示
  - [ ] 安装需求提示
  - [ ] 命令预览
  - [ ] 问题诊断

### 9.3 主页面
- [x] 主页布局（`lib/presentation/pages/home_page.dart`）
  - [x] 侧边栏导航
  - [x] 内容区域
  - [x] 工具栏
- [x] 服务器列表页（`lib/presentation/pages/servers_list_page.dart`）
  - [x] 服务器列表展示
  - [x] 搜索功能
  - [x] 排序功能
  - [x] 批量操作
- [ ] 服务器详情页（`lib/presentation/pages/server_detail_page.dart`）
  - [ ] 基本信息展示
  - [ ] 原始MCP配置展示
  - [ ] 解析后配置展示
  - [ ] 运行日志
  - [ ] 性能统计
  - [ ] 操作按钮

### 9.4 添加服务器页面（重新设计）
- [x] 添加服务器页（`lib/presentation/pages/config_import_page.dart`）
  - [x] MCP配置输入区域（必填）
  - [x] 配置分析按钮
  - [x] 分析结果展示
  - [x] 安装源配置区域
  - [x] 安装进度显示
  - [x] 错误处理和重试
- [ ] MCP配置输入组件（`lib/presentation/widgets/mcp_config_input.dart`）
  - [ ] JSON格式验证
  - [ ] 语法高亮
  - [ ] 示例配置提示
  - [ ] 格式化功能
- [ ] 安装源配置组件（`lib/presentation/widgets/install_source_config.dart`）
  - [ ] 动态显示需要配置的服务器
  - [ ] 包名/GitHub地址输入
  - [ ] 验证提示
  - [ ] 自动补全建议

### 9.5 关于页面
- [ ] 关于页面（`lib/presentation/pages/about_page.dart`）
  - [ ] 应用信息
  - [ ] 版本信息
  - [ ] 开源协议
  - [ ] 联系方式

### 9.6 设置页面
- [x] 设置页面（`lib/presentation/pages/settings_page.dart`）
  - [x] 应用设置
  - [x] 主题设置
  - [x] 日志级别设置
  - [x] 自动清理设置

---

## 📋 **第十阶段：状态管理**

### 10.1 全局状态管理
- [ ] 应用状态提供器（`lib/presentation/providers/app_state_provider.dart`）
  - [ ] 应用初始化状态
  - [ ] 主题状态
  - [ ] 设置状态
- [x] 服务器状态提供器（`lib/presentation/providers/servers_provider.dart`）
  - [x] 服务器列表状态
  - [x] 服务器详情状态
  - [x] 服务器操作状态
- [ ] 安装状态提供器（`lib/presentation/providers/install_provider.dart`）
  - [ ] 配置分析状态
  - [ ] 安装策略状态
  - [ ] 安装进度状态
  - [ ] 安装历史状态
  - [ ] 安装错误状态

### 10.2 业务逻辑用例
- [ ] 服务器管理用例（`lib/domain/usecases/server_management_usecases.dart`）
  - [ ] 基于MCP配置添加服务器用例
  - [ ] 删除服务器用例
  - [ ] 启动服务器用例（使用解析后的命令）
  - [ ] 停止服务器用例
  - [ ] 更新服务器用例
- [ ] 配置管理用例（`lib/domain/usecases/config_management_usecases.dart`）
  - [ ] MCP配置分析用例
  - [ ] 安装策略生成用例
  - [ ] 配置验证用例
- [ ] 安装管理用例（`lib/domain/usecases/install_management_usecases.dart`）
  - [ ] 策略化安装用例
  - [ ] 源码安装用例
  - [ ] 安装验证用例

---

## 📋 **第十一阶段：系统集成**

### 11.1 桌面功能集成
- [ ] 窗口管理（`lib/core/services/window_service.dart`）
  - [ ] 窗口大小和位置
  - [ ] 最小化到托盘
  - [ ] 关闭行为设置
- [ ] 托盘管理（`lib/core/services/tray_service.dart`）
  - [ ] 托盘图标
  - [ ] 托盘菜单
  - [ ] 托盘通知
- [ ] 系统通知（`lib/core/services/notification_service.dart`）
  - [ ] 安装完成通知
  - [ ] 错误通知
  - [ ] 状态变更通知

### 11.2 应用生命周期
- [ ] 应用启动器（`lib/core/services/app_launcher.dart`）
  - [ ] 应用初始化
  - [ ] 运行时环境检查
  - [ ] 数据库初始化
  - [ ] 服务启动
- [ ] 应用清理器（`lib/core/services/app_cleaner.dart`）
  - [ ] 资源清理
  - [ ] 进程清理
  - [ ] 临时文件清理

---

## 📋 **第十二阶段：错误处理和日志**

### 12.1 异常处理
- [ ] 自定义异常类（`lib/core/exceptions/`）
  - [ ] `RuntimeException` - 运行时异常
  - [ ] `InstallException` - 安装异常
  - [ ] `ConfigException` - 配置异常
  - [ ] `NetworkException` - 网络异常
  - [ ] `DatabaseException` - 数据库异常
- [ ] 全局异常处理器（`lib/core/services/exception_handler.dart`）
  - [ ] 异常捕获
  - [ ] 异常记录
  - [ ] 用户友好错误提示

### 12.2 日志系统
- [x] 日志配置（`lib/core/services/log_service.dart`）
  - [x] 日志级别配置
  - [x] 日志文件管理
  - [x] 日志格式化
- [x] 应用日志记录
  - [x] 系统启动日志
  - [x] 操作日志
  - [x] 错误日志
  - [x] 性能日志

---

## 📋 **第十三阶段：测试**

### 13.1 单元测试
- [ ] 核心服务测试（`test/core/`）
  - [ ] 运行时管理器测试
  - [ ] 环境管理器测试
  - [ ] 配置管理器测试
- [ ] 数据层测试（`test/data/`）
  - [ ] 数据库服务测试
  - [ ] 数据模型测试
  - [ ] 仓库实现测试
- [ ] 业务逻辑测试（`test/domain/`）
  - [ ] 用例测试
  - [ ] 实体测试

### 13.2 集成测试
- [ ] MCP协议集成测试
- [ ] MCP配置解析集成测试
- [ ] GitHub安装集成测试
- [ ] 数据库集成测试

### 13.3 UI测试
- [ ] 主要页面测试
- [ ] 组件交互测试
- [ ] 用户流程测试

---

## 📋 **第十四阶段：打包和分发**

### 14.1 应用图标和资源
- [ ] 设计应用图标
- [ ] 准备不同尺寸图标
- [ ] 配置应用元数据

### 14.2 打包配置
- [ ] Windows打包配置
  - [ ] MSI安装包
  - [ ] 数字签名（如需要）
- [ ] macOS打包配置
  - [ ] DMG安装包
  - [ ] 代码签名（如需要）
- [ ] Linux打包配置
  - [ ] AppImage/Snap/Flatpak

### 14.3 运行时资源打包
- [ ] 创建assets目录结构
- [ ] 手动下载运行时资源（用户负责）：
  - [ ] Python 3.12.6 embeddable版本（Windows）
  - [ ] Python 3.12.6 预编译版本（Linux/macOS）
  - [ ] UV 0.4.18 预编译版本
  - [ ] Node.js 20.10.0 预编译版本
- [ ] 验证资源完整性
- [ ] 配置Flutter assets引用

---

## 📋 **第十五阶段：文档和发布**

### 15.1 用户文档
- [ ] 安装指南
- [ ] 使用教程
- [ ] 常见问题解答
- [ ] 故障排除指南

### 15.2 开发者文档
- [ ] API文档
- [ ] 架构说明
- [ ] 贡献指南
- [ ] 代码规范

### 15.3 发布准备
- [ ] 版本号管理
- [ ] 变更日志
- [ ] 发布说明
- [ ] GitHub Release准备

---

## 📋 **重要业务逻辑说明**

### MCP Server 管理核心逻辑
1. **MCP Server配置（mcpServers）是必填核心**
   - 包含启动命令、环境变量等关键信息
   - 所有MCP Server都必须有正确的配置才能运行

2. **安装功能 = 安装 + 添加**
   - 用户配置mcpServers后，系统自动判断安装方式
   - 安装完成后自动添加到服务器列表

3. **自动安装策略判断**
   - 如果配置中使用 `uvx`/`npx` → 无需额外安装步骤
   - 如果不是 → 需要额外安装（本地路径、GitHub源码等）

## 📋 **高优先级任务**

### 1. 重构安装向导页面 ✅ (需要重新设计)
- [x] ~~创建基础安装向导界面~~
- [ ] **重新设计：以mcpServers配置为核心的安装流程**
  - [ ] 第一步：配置mcpServers（必填）
  - [ ] 第二步：根据配置自动判断安装方式
  - [ ] 第三步：如果需要额外安装，提供安装选项
  - [ ] 第四步：执行安装并添加到服务器列表

### 2. 简化添加服务器功能
- [ ] **将添加功能合并到安装功能中**
- [ ] 保留独立的"从配置文件导入"功能
- [ ] 移除重复的添加入口

### 3. 完善包管理器服务 ✅ (需要优化)
- [x] ~~支持多种安装策略~~
- [ ] **优化：根据mcpServers配置自动选择策略**
- [ ] **新增：GitHub源码分析和自动安装**
- [ ] **新增：本地路径安装支持**

### 4. 优化用户界面
- [ ] **重新设计主界面按钮布局**
  - [ ] 主要按钮：安装MCP Server
  - [ ] 次要按钮：从配置导入
- [ ] **优化安装向导的用户体验**
- [ ] **添加安装进度和状态反馈**

## 📋 **中优先级任务**

### 5. 增强GitHub源码分析器 ✅ (已修复)
- [x] 修复编译错误
- [x] 支持多种项目类型检测
- [ ] **集成到安装流程中**

### 6. 完善服务器监控功能
- [ ] 实时状态监控
- [ ] 日志查看功能
- [ ] 性能指标展示

### 7. 配置管理优化
- [ ] 配置验证和错误提示
- [ ] 配置模板和预设
- [ ] 批量导入导出

## 📋 **低优先级任务**

### 8. 高级功能
- [ ] 服务器分组管理
- [ ] 备份和恢复
- [ ] 插件系统扩展

### 9. 用户体验优化
- [ ] 主题定制
- [ ] 快捷键支持
- [ ] 多语言支持

### 10. 文档和帮助
- [ ] 用户手册
- [ ] 视频教程
- [ ] FAQ文档

## 📋 **技术债务**

### 数据库优化
- [ ] 添加索引优化查询性能
- [ ] 数据迁移脚本

### 代码质量
- [ ] 单元测试覆盖
- [ ] 集成测试
- [ ] 代码规范检查

### 性能优化
- [ ] 内存使用优化
- [ ] 启动速度优化
- [ ] 响应性能提升

## 📋 **已完成任务 ✅**

- [x] 修复GitHub源码分析器编译错误
- [x] 创建包管理器服务基础框架
- [x] 创建安装向导页面基础界面
- [x] 修复服务器列表页面布局溢出问题
- [x] 优化界面布局，解决RenderFlex溢出错误

---

## 📅 **开发里程碑建议**

### 里程碑1：基础架构（预计2-3周）
完成第1-3阶段的所有🔴高优先级任务

### 里程碑2：核心功能（预计4-5周）  
完成第4-8阶段的所有🔴高优先级任务

### 里程碑3：用户界面（预计2-3周）
完成第9-10阶段的基础UI功能

### 里程碑4：系统集成（预计1-2周）
完成第11-12阶段的集成和优化

### 里程碑5：测试和发布（预计1-2周）
完成第13-15阶段的测试和发布准备

---

## 📝 **开发说明**

1. **运行时资源**：按照需求文档中的下载清单，手动下载所需的Python、UV、Node.js运行时文件
2. **测试策略**：每完成一个模块，立即编写对应的单元测试
3. **版本控制**：每完成一个功能点，及时提交代码并打标签
4. **文档更新**：重要功能完成后，及时更新文档
5. **性能监控**：关注应用启动时间、内存使用、数据库查询性能

---

**使用说明：** 
- 开发过程中，完成一项任务就在对应的 `[ ]` 中打勾 `[x]`
- 遇到问题或需要调整时，在对应任务后添加备注
- 建议按照优先级和里程碑顺序进行开发
- 可以根据实际情况调整任务的优先级和时间安排 