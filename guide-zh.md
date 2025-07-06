#### MCP管家使用说明

##### 一、下载MCP管家

- 进入[GitHub release](https://github.com/codai-agent/mcp-master-key/releases/)页面下载

- 区分自己的操作系统和CPU型号，下载对应的应用

  MacOS 支持 arm64 和 x64

  Windows 支持 x86-x64

  Linux桌面版本暂未打包

##### 二、MCP管家使用说明

###### 1、界面整体介绍

左侧：功能导航区域

右侧：功能操作区域

顶部：菜单区

<img width="1200" alt="1" src="https://github.com/user-attachments/assets/fbf5a9f1-5371-4489-b941-607121be6650" />

###### 2、安装MCP服务器

（**截止到v0.0.2版本，暂时只支持npx/uvx的安装命令**）

2-1、MCP server配置文件快捷安装：点击“安装服务器”-“MCP配置”区域输入MCP server配置，比如输入查询世界主要城市的时间的MCP配置：

"time": {
      "command": "uvx",
      "args": ["mcp-server-time","--local-timezone","America/New_York"],
      "type": "stdio"
    }

<img width="1200" alt="2" src="https://github.com/user-attachments/assets/47a4fbd1-379b-4a13-abbc-c450e608845e" />

2-2、点击“分析配置”-一路下一步直到“执行安装”页-点击“开始安装”，等等安装完成。

（**如果中国大陆用户的安装一直卡住，可以点击“设置”页面，下拉找到“下载设置”，打开启用镜像的开关，这样可以起到加速安装的效果**）

<img width="1197" alt="3" src="https://github.com/user-attachments/assets/49743e9f-70cf-49c5-971b-c818ed79b77b" />

2-3、也可以通过uvx/npx命令进行“快速配置”，比如在“安装命令”中填入：npx -y @wopal/mcp-server-hotnews，然后点击“解析命令”，会自动填写一个MCP服务的配置，然后后续操作参考2-2

<img width="1200" alt="4" src="https://github.com/user-attachments/assets/375da95d-7610-458f-9d04-d514d043fccb" />

2-4、无论是快速配置还是通过MCP服务配置进行安装，请为每一个安装的MCP server填写：服务器名称 与 服务器描述，这样方便后面查看和理解这个服务器的功能。

<img width="1188" alt="5" src="https://github.com/user-attachments/assets/2cfbd2bd-e117-4f22-a7b4-c4ad9b41eb28" />

##### 三、服务器的管理

###### 1、服务器进程的管理

1-1、启动服务器

​    点击启动按钮启动服务

<img width="1186" alt="6" src="https://github.com/user-attachments/assets/8ed88778-fd01-4c95-867e-1d5d9278a691" />

1-2、关闭服务器

​    点击停止按钮关闭服务

<img width="1189" alt="7" src="https://github.com/user-attachments/assets/94d1aa57-49cd-4367-a344-c67ed948707d" />

1-3、删除服务器

​    点击删除菜单来删除服务

<img width="1200" alt="8" src="https://github.com/user-attachments/assets/d918bea2-b72f-4638-a05f-3e61ec2ed808" />

1-4、查看MCP server的工具

​    点击进入服务器监控页面-‘统计’-‘工具统计’即可查看

##### 四、外部MCP hub/client如何调用MCP管家中配置的服务

MCP管家对外可以提供SSE或者是StreamableHttp服务，前者只支持一个MCP 客户端去调用MCP管家里面安装的服务，后者支持多个MCP客户端去使用MCP管家中的服务，比如同时使用多个Codai客户端去连接MCP管家，或者cursor与cherry studio同时去连接等场景。

###### 1、SSE模式

点击首页上方的“查看MCP配置”，会弹出MCP服务器管家对外提供的MCP服务器配置，可以复制完整的mcpservers内容，也可以只去选择“mcphub”部分然后右键复制内容
<img width="913" alt="9" src="https://github.com/user-attachments/assets/396d636d-0eac-4ae2-bf81-68a1ab3a5691" />

我们以Codai编程客户端为例，将“mcphub”的内容复后，点开Codai的MCP设置中“Installed ”,再点击“配置MCP服务”，打开MCP server配置的json文件，将内容粘贴进去：

<img width="1032" alt="11" src="https://github.com/user-attachments/assets/9f2c9912-ab8b-4431-bbf9-b496d8ae46d0" />

###### 2、StreamableHttp模式

点击“设置”-找到“Hub设置”，选择“Streamable”模式，重启服务既可

<img width="1200" alt="10" src="https://github.com/user-attachments/assets/9570f2e9-279b-4550-b5f1-6add2145488e" />

再回到首页-点击“查看MCP配置”

<img width="644" alt="12" src="https://github.com/user-attachments/assets/02c52ed7-4d52-4a1d-aa26-d869f50e83e3" />
