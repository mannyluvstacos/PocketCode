# PocketCode Architecture & Network Security

## Overview

PocketCode is a setup script that enables running AI coding agents (OpenCode, Claude Code, Gemini CLI) locally on Android devices using Termux. This document explains the architecture, setup process, and network communication patterns.

## How PocketCode Works

### 1. Setup Phase (One-Time)

When you run the setup script, it performs the following steps:

```bash
curl -sL https://raw.githubusercontent.com/rajbreno/PocketCode/main/setup.sh | bash
```

**Network Requests During Setup:**

1. **GitHub Raw Content** (`https://raw.githubusercontent.com/rajbreno/PocketCode/main/setup.sh`)
   - **Purpose**: Download the setup script
   - **Data Sent**: None (HTTP GET request)
   - **Data Received**: The setup.sh bash script

2. **Termux Package Repositories** (via `pkg update` and `pkg upgrade`)
   - **Purpose**: Update Termux packages and install proot-distro
   - **Data Sent**: Package queries to Termux official mirrors
   - **Data Received**: Package metadata and binaries

3. **Debian Package Repositories** (via `apt update` and `apt install`)
   - **Purpose**: Install Linux packages inside the Debian container
   - **Packages**: curl, git, build-essential, python3, nodejs
   - **Data Sent**: Package queries to official Debian mirrors
   - **Data Received**: Package metadata and binaries

4. **NodeSource Repository** (`https://deb.nodesource.com/setup_20.x`)
   - **Purpose**: Setup Node.js 20.x repository
   - **Data Sent**: None (HTTP GET request)
   - **Data Received**: Repository configuration script

5. **OpenCode Installer** (`https://opencode.ai/install`)
   - **Purpose**: Install OpenCode CLI tool
   - **Data Sent**: None (HTTP GET request)
   - **Data Received**: OpenCode installation script

**Important**: All setup requests go to:
- GitHub (open source repository hosting)
- Official Termux/Debian package mirrors (vetted software repositories)
- NodeSource (official Node.js distribution)
- OpenCode.ai (the AI coding agent installer)

### 2. Runtime Phase (During Use)

After setup, when you run `opencode` or other AI coding agents:

**Network Communication:**

1. **LLM Provider API Only**
   - When using OpenCode: Requests go ONLY to your configured LLM provider (OpenAI, Anthropic, etc.)
   - **Data Sent**: Your prompts and code context
   - **Data Received**: LLM responses and code suggestions
   - **Authentication**: Uses YOUR API key configured during OpenCode setup

2. **No Third-Party Analytics**
   - PocketCode itself makes NO network requests during runtime
   - OpenCode communicates ONLY with the authenticated LLM provider
   - No telemetry, analytics, or tracking

3. **Local File System**
   - All code and projects are stored locally in Termux's sandboxed filesystem
   - Other Android apps CANNOT access these files (Android security model)
   - Only accessible through Termux and apps granted explicit storage permissions

## Security Model

### Data Privacy Guarantees

1. **Code Privacy**
   - Your code stays on your device
   - Only sent to the LLM provider YOU choose and authenticate
   - Not sent to any PocketCode servers (there are none)

2. **Sandboxed Environment**
   - Runs in Termux's private filesystem
   - Android's app sandboxing prevents other apps from accessing your code
   - Even with root access on device, other apps can't read Termux files

3. **No Telemetry**
   - PocketCode is just a setup script - it doesn't run continuously
   - No usage tracking or analytics
   - No "phone home" functionality

4. **Open Source**
   - All code is available at https://github.com/rajbreno/PocketCode
   - You can audit the setup.sh script before running it
   - No obfuscated or hidden code

## Network Flow Diagram

```
SETUP PHASE:
[Your Device] --GET--> [GitHub] (setup.sh)
[Your Device] --GET--> [Termux Repos] (proot-distro)
[Your Device] --GET--> [Debian Repos] (dev tools)
[Your Device] --GET--> [NodeSource] (Node.js)
[Your Device] --GET--> [OpenCode.ai] (opencode installer)

RUNTIME PHASE:
[Your Code] --Local--> [OpenCode/AI Agent] --API--> [Your LLM Provider]
                                                      (OpenAI/Anthropic/etc)
                                                      using YOUR API key

No other network communication occurs.
```

## Verification Methods

See [NETWORK_VERIFICATION.md](NETWORK_VERIFICATION.md) for detailed instructions on how to verify network traffic yourself.

## Components Installed

1. **proot-distro**: Linux container system (from Termux official repos)
2. **Debian**: Base Linux distribution (from official Debian mirrors)
3. **Node.js**: JavaScript runtime (from official NodeSource)
4. **OpenCode**: AI coding agent (from opencode.ai)
5. **Development Tools**: curl, git, build-essential, python3 (from Debian repos)

All components are from official, verified sources.

## What Happens to Your Data

| Data Type | Where It Goes | Who Can Access |
|-----------|---------------|----------------|
| Your code files | Local filesystem (Termux sandbox) | Only you (via Termux) |
| Your prompts to AI | Your chosen LLM provider | You + LLM provider |
| LLM responses | Local filesystem (Termux sandbox) | Only you (via Termux) |
| Setup metadata | Nowhere (not collected) | N/A |
| Usage analytics | Nowhere (not collected) | N/A |

## Third-Party Services Used

### During Setup Only:
- **GitHub**: Hosts this repository and setup script
- **Termux Repos**: Official Termux package mirrors
- **Debian Repos**: Official Debian package mirrors  
- **NodeSource**: Official Node.js distribution
- **OpenCode.ai**: Hosts OpenCode installer

### During Runtime:
- **Your LLM Provider ONLY**: OpenAI, Anthropic, Google, or whatever you configure with OpenCode
  - You provide the API key
  - You control what provider is used
  - You can monitor all requests (see NETWORK_VERIFICATION.md)

### Never Used:
- No PocketCode backend servers (don't exist)
- No analytics services
- No telemetry endpoints
- No tracking pixels or beacons

## Frequently Asked Questions

### Q: Where is my code stored?
A: Locally in `/data/data/com.termux/files/home/` on your Android device. This is sandboxed and inaccessible to other apps.

### Q: Can other apps see my code?
A: No. Android's app sandboxing prevents other apps from accessing Termux's filesystem.

### Q: What network requests happen when I use OpenCode?
A: Only requests to your configured LLM provider (e.g., OpenAI API at api.openai.com) using YOUR API key.

### Q: Does PocketCode send my code anywhere?
A: PocketCode is just a setup script. OpenCode (the AI agent) sends your prompts and code context to YOUR chosen LLM provider - nowhere else.

### Q: How can I verify this?
A: See [NETWORK_VERIFICATION.md](NETWORK_VERIFICATION.md) for step-by-step instructions to monitor network traffic.

### Q: Is my API key safe?
A: Yes. Your API key is stored locally in OpenCode's configuration and used only to authenticate with your LLM provider. It never leaves your device except to make API calls to that provider.

## Conclusion

PocketCode provides a secure, private environment for AI-assisted coding on Android:
- ✅ Open source and auditable
- ✅ No analytics or telemetry
- ✅ Code stays on your device
- ✅ Only communicates with YOUR authenticated LLM provider
- ✅ Sandboxed and isolated from other apps

For verification instructions, see [NETWORK_VERIFICATION.md](NETWORK_VERIFICATION.md).
