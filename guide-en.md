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

<img width="1200" alt="1" src="https://github.com/user-attachments/assets/fbf5a9f1-5371-4489-b941-607121be6650" />


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

<img width="1200" alt="2" src="https://github.com/user-attachments/assets/47a4fbd1-379b-4a13-abbc-c450e608845e" />


2-2. Click "Analyze Config" → Proceed through steps until "Execute Installation" page → Click "Start Installation" and wait for completion.

(**For users in Mainland China experiencing slow downloads, go to "Settings" page, find "Download Settings", and enable mirror mode to speed up installation**)

<img width="1197" alt="3" src="https://github.com/user-attachments/assets/49743e9f-70cf-49c5-971b-c818ed79b77b" />


2-3. Alternatively, use "Quick Config" with uvx/npx commands. For example, enter in "Install Command": `npx -y @wopal/mcp-server-hotnews`, then click "Parse Command" to auto-fill MCP service config. Then follow steps from 2-2.

<img width="1200" alt="4" src="https://github.com/user-attachments/assets/375da95d-7610-458f-9d04-d514d043fccb" />


2-4. Whether using Quick Config or manual MCP service config, provide a "Server Name" and "Server Description" for each installed MCP server to help identify its purpose later.

<img width="1188" alt="5" src="https://github.com/user-attachments/assets/2cfbd2bd-e117-4f22-a7b4-c4ad9b41eb28" />


##### 3. Server Management

###### 1. Server Process Management

1-1. Start server  
Click the start button to launch service  

<img width="1186" alt="6" src="https://github.com/user-attachments/assets/8ed88778-fd01-4c95-867e-1d5d9278a691" />


1-2. Stop server  
Click the stop button to terminate service  

<img width="1189" alt="7" src="https://github.com/user-attachments/assets/94d1aa57-49cd-4367-a344-c67ed948707d" />


1-3. Delete server  
Click delete menu to remove service  

<img width="1200" alt="8" src="https://github.com/user-attachments/assets/d918bea2-b72f-4638-a05f-3e61ec2ed808" />


1-4. View MCP server tools  
Go to server monitoring page → 'Statistics' → 'Tool Statistics' to view  

##### 4. How External MCP Hub/Clients Can Use Services Configured in MCP Master Key

MCP Master Key can provide either SSE or StreamableHttp services. SSE only supports one MCP client connection, while StreamableHttp supports multiple clients (e.g., multiple Codai clients connecting simultaneously, or Cursor and Cherry Studio connecting together).

###### 1. SSE Mode

Click "View MCP Config" at the top of the home page to see the MCP server configuration provided by MCP Master Key. You can copy the full mcpservers content or just select the "mcphub" section and right-click to copy.  

<img width="913" alt="9" src="https://github.com/user-attachments/assets/396d636d-0eac-4ae2-bf81-68a1ab3a5691" />


For example with Codai programming client:  
After copying "mcphub" content, go to Codai's MCP Settings → "Installed" → Click "Configure MCP Service" → Open MCP server config JSON file and paste the content:  

<img width="1032" alt="11" src="https://github.com/user-attachments/assets/9f2c9912-ab8b-4431-bbf9-b496d8ae46d0" />


###### 2. StreamableHttp Mode

Go to "Settings" → Find "Hub Settings" → Select "Streamable" mode → Restart service  

<img width="1200" alt="10" src="https://github.com/user-attachments/assets/9570f2e9-279b-4550-b5f1-6add2145488e" />


Then return to home page → Click "View MCP Config"  

<img width="644" alt="12" src="https://github.com/user-attachments/assets/02c52ed7-4d52-4a1d-aa26-d869f50e83e3" />

