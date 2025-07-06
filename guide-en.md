#### MCP Master Key User Guide

##### 1. Download MCP Master Key

- Visit [GitHub release](https://github.com/codai-agent/mcp-master-key/releases/) page to download
- Select the correct version for your operating system and CPU architecture:
  - MacOS supports arm64 and x64
  - Windows supports x86-x64
  - Linux desktop version is not currently packaged

##### 2. Using MCP Master Key

###### 1. Interface Overview

Left side: Function navigation area  
Right side: Operation area  
Top: Menu bar  

![1](1.png)

###### 2. Installing MCP Server

(**As of v0.0.2, only npx/uvx installation commands are supported**)

2-1. Quick MCP server configuration installation:
Click "Install Server" → Enter MCP server configuration in "MCP Config" area. For example, to install a server that queries world city times:

```json
"time": {
  "command": "uvx",
  "args": ["mcp-server-time","--local-timezone","America/New_York"],
  "type": "stdio"
}
```

![2](2.png)

2-2. Click "Analyze Config" → Proceed through steps until "Execute Installation" page → Click "Start Installation" and wait for completion.

(**For users in Mainland China experiencing slow downloads, go to "Settings" page, find "Download Settings", and enable mirror mode to speed up installation**)

![3](3.png)

2-3. Alternatively, use "Quick Config" with uvx/npx commands. For example, enter in "Install Command": `npx -y @wopal/mcp-server-hotnews`, then click "Parse Command" to auto-fill MCP service config. Then follow steps from 2-2.

![4](4.png)

2-4. Whether using Quick Config or manual MCP service config, provide a "Server Name" and "Server Description" for each installed MCP server to help identify its purpose later.

![5](5.png)

##### 3. Server Management

###### 1. Server Process Management

1-1. Start server  
Click the start button to launch service  

![6](6.png)

1-2. Stop server  
Click the stop button to terminate service  

![7](7.png)

1-3. Delete server  
Click delete menu to remove service  

![8](8.png)

1-4. View MCP server tools  
Go to server monitoring page → 'Statistics' → 'Tool Statistics' to view  

##### 4. How External MCP Hub/Clients Can Use Services Configured in MCP Master Key

MCP Master Key can provide either SSE or StreamableHttp services. SSE only supports one MCP client connection, while StreamableHttp supports multiple clients (e.g., multiple Codai clients connecting simultaneously, or Cursor and Cherry Studio connecting together).

###### 1. SSE Mode

Click "View MCP Config" at the top of the home page to see the MCP server configuration provided by MCP Master Key. You can copy the full mcpservers content or just select the "mcphub" section and right-click to copy.  

![9](9.png)

For example with Codai programming client:  
After copying "mcphub" content, go to Codai's MCP Settings → "Installed" → Click "Configure MCP Service" → Open MCP server config JSON file and paste the content:  

![11](11.png)

###### 2. StreamableHttp Mode

Go to "Settings" → Find "Hub Settings" → Select "Streamable" mode → Restart service  

![10](10.png)

Then return to home page → Click "View MCP Config"  

![12](12.png)
