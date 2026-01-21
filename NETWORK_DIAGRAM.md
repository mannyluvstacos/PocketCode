# PocketCode Network Flow Diagram

This document provides visual representations of PocketCode's network communication.

## Setup Phase Network Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         SETUP PHASE                                  │
│                    (One-time installation)                           │
└─────────────────────────────────────────────────────────────────────┘

Step 1: Download Setup Script
┌──────────────┐    HTTPS GET    ┌──────────────────────────┐
│ Your Android │ ───────────────> │ raw.githubusercontent.com │
│   Device     │ <─────────────── │   (GitHub)               │
└──────────────┘    setup.sh      └──────────────────────────┘

Step 2: Install Termux Packages
┌──────────────┐    pkg install   ┌──────────────────────────┐
│   Termux     │ ───────────────> │ Termux Package Repos     │
│              │ <─────────────── │ (*.termux.dev)           │
└──────────────┘    proot-distro  └──────────────────────────┘

Step 3: Install Debian Packages
┌──────────────┐    apt install   ┌──────────────────────────┐
│   Debian     │ ───────────────> │ Debian Package Repos     │
│  Container   │ <─────────────── │ (deb.debian.org)         │
└──────────────┘    dev tools     └──────────────────────────┘

Step 4: Setup Node.js
┌──────────────┐    HTTPS GET    ┌──────────────────────────┐
│   Debian     │ ───────────────> │ deb.nodesource.com       │
│  Container   │ <─────────────── │ (Official Node.js)       │
└──────────────┘    Node 20 setup └──────────────────────────┘

Step 5: Install OpenCode
┌──────────────┐    HTTPS GET    ┌──────────────────────────┐
│   Debian     │ ───────────────> │ opencode.ai              │
│  Container   │ <─────────────── │ (AI Agent Installer)     │
└──────────────┘    opencode CLI  └──────────────────────────┘

✓ Setup Complete - No more setup-related network requests
```

## Runtime Phase Network Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                        RUNTIME PHASE                                 │
│              (When you use OpenCode for coding)                      │
└─────────────────────────────────────────────────────────────────────┘

User Interaction
┌──────────────┐
│     You      │  "Create a React app"
│   (Prompt)   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   OpenCode   │  Processes prompt, reads local files
│   (Local)    │
└──────┬───────┘
       │
       │ HTTPS POST (with YOUR API key)
       │ Payload: Prompt + Code Context
       │
       ▼
┌──────────────────────────┐
│  YOUR LLM Provider       │  Examples:
│  (YOUR choice)           │  • api.openai.com
│                          │  • api.anthropic.com
│  Uses YOUR API Key       │  • generativelanguage.googleapis.com
└──────┬───────────────────┘
       │
       │ HTTPS Response
       │ Payload: AI-generated code/suggestions
       │
       ▼
┌──────────────┐
│   OpenCode   │  Receives response, applies changes
│   (Local)    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Local Files │  Code saved to device
│   (Termux)   │  /data/data/com.termux/files/home/
└──────────────┘

❌ NO analytics endpoints
❌ NO telemetry servers
❌ NO tracking services
❌ NO third-party data collection
✅ ONLY your authenticated LLM provider
```

## Data Flow Summary

```
┌─────────────────────────────────────────────────────────────────────┐
│                    WHAT HAPPENS TO YOUR DATA                         │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────┐
│  Your Code      │  Stored locally in Termux sandbox
│  Files          │  Path: /data/data/com.termux/files/home/
└────────┬────────┘  Access: Only you (via Termux)
         │           Protected: Android app sandboxing
         │
         ▼
┌─────────────────┐
│  Your Prompts   │  Sent ONLY to your LLM provider
│  to AI          │  Uses: YOUR API key
└────────┬────────┘  Encrypted: HTTPS/TLS
         │
         ▼
┌─────────────────┐
│  LLM Provider   │  OpenAI / Anthropic / Google / Your choice
│  (YOU choose)   │  Privacy Policy: Check your provider's policy
└────────┬────────┘  Data handling: Per provider's terms
         │
         ▼
┌─────────────────┐
│  AI Responses   │  Received and stored locally
│                 │  Path: /data/data/com.termux/files/home/
└─────────────────┘  Access: Only you (via Termux)

❌ Never sent to PocketCode servers (they don't exist)
❌ Never sent to analytics services
❌ Never shared with third parties
```

## Security Boundaries

```
┌─────────────────────────────────────────────────────────────────────┐
│                      ANDROID DEVICE                                  │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                    TERMUX APP SANDBOX                          │  │
│  │  (Isolated from other Android apps)                           │  │
│  │                                                                │  │
│  │  ┌─────────────────────────────────────────────────────────┐  │  │
│  │  │              DEBIAN CONTAINER (proot)                    │  │  │
│  │  │  (Additional isolation layer)                           │  │  │
│  │  │                                                          │  │  │
│  │  │  ┌─────────────┐    ┌─────────────┐                     │  │  │
│  │  │  │  Your Code  │    │  OpenCode   │                     │  │  │
│  │  │  │   Files     │───>│    CLI      │                     │  │  │
│  │  │  └─────────────┘    └──────┬──────┘                     │  │  │
│  │  │                             │                            │  │  │
│  │  └─────────────────────────────┼────────────────────────────┘  │  │
│  │                                │                               │  │
│  └────────────────────────────────┼───────────────────────────────┘  │
│                                   │                                  │
│                                   │ HTTPS (encrypted)                │
└───────────────────────────────────┼──────────────────────────────────┘
                                    │
                         INTERNET   │   FIREWALL
                                    │
                                    ▼
                      ┌──────────────────────────┐
                      │   LLM Provider API       │
                      │   (YOUR authenticated)   │
                      │                          │
                      │  • api.openai.com        │
                      │  • api.anthropic.com     │
                      │  • etc.                  │
                      └──────────────────────────┘

Security Features:
✓ Android app sandboxing - Other apps can't read Termux files
✓ proot containerization - Additional isolation
✓ HTTPS/TLS encryption - Network traffic encrypted
✓ API key authentication - Only YOU can make requests
✓ No telemetry - No data sent to analytics services
```

## Network Monitoring Points

Where you can monitor/verify network traffic:

```
┌─────────────────────────────────────────────────────────────────────┐
│                   VERIFICATION POINTS                                │
└─────────────────────────────────────────────────────────────────────┘

1. Android System Level
   ┌──────────────────────┐
   │  NetGuard / PCAPdroid│  Monitor all app network connections
   │  (No root required)  │  See exactly what domains are contacted
   └──────────────────────┘

2. Termux Level
   ┌──────────────────────┐
   │  tcpdump / strace    │  Monitor process network activity
   │  (Inside Termux)     │  See all connection attempts
   └──────────────────────┘

3. Code Level
   ┌──────────────────────┐
   │  Source Code Audit   │  Review setup.sh line by line
   │  (GitHub)            │  See exactly what gets downloaded
   └──────────────────────┘

4. Configuration Level
   ┌──────────────────────┐
   │  OpenCode Config     │  Check ~/.opencode/config.json
   │  (Local file)        │  Verify API endpoint configuration
   └──────────────────────┘
```

## Comparison: What OTHER Apps Might Do vs PocketCode

```
┌─────────────────────────────────────────────────────────────────────┐
│                 TYPICAL CLOUD-BASED CODING TOOLS                     │
└─────────────────────────────────────────────────────────────────────┘

Your Code ──> Vendor Server ──> Analytics ──> LLM Provider
              │                  │
              ├──> Telemetry     ├──> Marketing Pixels
              │                  │
              └──> User Tracking └──> Third-party Services

❌ Your code stored on vendor servers
❌ Usage tracked and analyzed
❌ Potential data sharing with third parties
❌ Multiple network hops and exposure points


┌─────────────────────────────────────────────────────────────────────┐
│                         POCKETCODE                                   │
└─────────────────────────────────────────────────────────────────────┘

Your Code ──> OpenCode (Local) ──> YOUR LLM Provider
   │                                (Direct connection)
   └──> Stays on device

✅ Your code never leaves except to YOUR chosen LLM
✅ No analytics or telemetry
✅ No third-party services
✅ Direct connection to LLM provider
✅ Open source and auditable
```

## Quick Reference

**Setup Endpoints (One-time only):**
- raw.githubusercontent.com (setup script)
- Termux/Debian package repos (official packages)
- deb.nodesource.com (official Node.js)
- opencode.ai (AI agent installer)

**Runtime Endpoints (Every use):**
- YOUR LLM provider API only (api.openai.com, api.anthropic.com, etc.)

**Never Contacted:**
- Analytics services (Google Analytics, Mixpanel, etc.)
- Telemetry endpoints
- Advertising networks
- Social media trackers
- Any other third parties

---

**Verification:**
Run `./verify_network.sh` to automatically verify all of the above.

See also:
- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed architecture
- [NETWORK_VERIFICATION.md](NETWORK_VERIFICATION.md) - How to verify yourself
