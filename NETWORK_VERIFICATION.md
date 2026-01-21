# Network Verification Guide

This guide provides step-by-step instructions for verifying that PocketCode only communicates with your authenticated LLM provider and no other third parties.

## Quick Summary

**What you'll verify:**
1. ✅ Setup script only downloads from official sources
2. ✅ Runtime only communicates with your LLM provider
3. ✅ No telemetry or analytics endpoints
4. ✅ No unexpected network connections

## Method 1: Monitor Network Traffic with Termux

### During Setup

Before running the setup, you can monitor what URLs are being contacted:

```bash
# Install a simple HTTP proxy to log requests
pkg install mitmproxy

# In one terminal, start the proxy
mitmdump --listen-port 8080

# In another terminal, run setup through the proxy
http_proxy=http://localhost:8080 https_proxy=http://localhost:8080 \
  curl -sL https://raw.githubusercontent.com/rajbreno/PocketCode/main/setup.sh | bash
```

**Expected connections during setup:**
- `raw.githubusercontent.com` - Downloading setup.sh
- `*.termux.dev` or `*.grimler.se` - Termux package repos
- `deb.debian.org` or `*.debian.org` - Debian packages
- `deb.nodesource.com` - Node.js repository
- `opencode.ai` - OpenCode installer

### During Runtime

Monitor OpenCode's network activity:

```bash
# Start OpenCode with network monitoring
strace -e trace=network opencode 2>&1 | grep connect
```

Or use tcpdump (requires root):

```bash
# Monitor all network connections
tcpdump -i any -n | grep -v "127.0.0.1"
```

**Expected connections during runtime:**
- `api.openai.com` (if using OpenAI)
- `api.anthropic.com` (if using Claude)
- `generativelanguage.googleapis.com` (if using Gemini)
- **NO OTHER ENDPOINTS**

## Method 2: Inspect the Source Code

The entire PocketCode repository is open source. You can audit it yourself:

```bash
# Clone the repository
git clone https://github.com/mannyluvstacos/PocketCode.git
cd PocketCode

# Search for all network requests in setup.sh
grep -n "curl\|wget\|http" setup.sh
```

**What you'll find:**

Line-by-line analysis of setup.sh:

```bash
# Line 25: Downloads Node.js setup script
curl -fsSL https://deb.nodesource.com/setup_20.x

# Line 27: Downloads OpenCode installer  
curl -fsSL https://opencode.ai/install
```

That's it! Only two curl commands, both to official/expected sources.

## Method 3: Use Android Network Monitoring Apps

### Option A: NetGuard (No Root Required)

1. Install [NetGuard](https://play.google.com/store/apps/details?id=eu.faircode.netguard) from Play Store
2. Enable NetGuard and configure it to log all connections
3. Run PocketCode setup or use OpenCode
4. Check NetGuard logs to see all connections

**Expected during setup:**
- Termux connecting to package repositories
- DNS queries for github.com, debian.org, nodesource.com, opencode.ai

**Expected during OpenCode usage:**
- Termux connecting to your LLM provider's API endpoint ONLY

### Option B: PCAPdroid (No Root Required)

1. Install [PCAPdroid](https://play.google.com/store/apps/details?id=com.emanuelef.remote_capture)
2. Start packet capture
3. Run OpenCode
4. Export and analyze the capture

Filter for Termux connections and verify they only go to your LLM provider.

## Method 4: DNS Query Monitoring

Monitor DNS queries to see what domains are being resolved:

```bash
# Inside Termux, monitor DNS queries
termux-api-install  # If not already installed
pkg install termux-api

# Then use Android's network monitoring
# Or manually check /etc/resolv.conf and dnstop if available
```

**Expected DNS queries:**
- During setup: github.com, debian.org, nodesource.com, opencode.ai
- During runtime: api.openai.com (or your LLM provider's domain)

## Method 5: Read OpenCode Configuration

OpenCode stores its configuration locally. You can verify what API endpoint it's configured to use:

```bash
# After setup, enter the Linux environment
pocketcode

# Check OpenCode configuration
cat ~/.opencode/config.json
# Or
opencode config list
```

**What to look for:**
- `api_endpoint` should be your LLM provider (e.g., https://api.openai.com)
- `api_key` should be YOUR key (redacted in display)
- No telemetry or analytics endpoints

## Method 6: Verify with cURL Test

Test the exact API calls OpenCode makes:

```bash
# Inside PocketCode/Debian environment
pocketcode

# Enable debug mode for OpenCode (if supported)
export OPENCODE_DEBUG=1
opencode "test prompt"

# This will show you the exact HTTP requests being made
```

Or manually test the API endpoint:

```bash
# Replace with your actual API key and endpoint
curl -v https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "gpt-4", "messages": [{"role": "user", "content": "test"}]}'

# Observe the connection - it goes to api.openai.com and nowhere else
```

## Method 7: Block All Traffic Except LLM Provider

Use a firewall to block all connections except to your LLM provider:

```bash
# Using iptables in Termux (if root available)
# OR use Android VPN-based firewall apps

# With NetGuard or similar firewall app:
# 1. Block all internet access for Termux
# 2. Whitelist ONLY your LLM provider's IP range
# 3. Try using OpenCode
# 4. If it works, that proves it only connects to the whitelisted provider
```

## Expected Network Endpoints by Phase

### Setup Phase

| Endpoint | Purpose | Required |
|----------|---------|----------|
| raw.githubusercontent.com | Download setup.sh | Yes |
| Termux package repos | Install proot-distro | Yes |
| Debian package repos | Install dev tools | Yes |
| deb.nodesource.com | Setup Node.js repo | Yes |
| opencode.ai | Install OpenCode | Yes |

### Runtime Phase

| Endpoint | Purpose | Required |
|----------|---------|----------|
| api.openai.com | OpenAI API (if configured) | Only if using OpenAI |
| api.anthropic.com | Claude API (if configured) | Only if using Claude |
| generativelanguage.googleapis.com | Gemini API (if configured) | Only if using Gemini |
| **NO OTHER ENDPOINTS** | - | - |

## Red Flags to Watch For

If you see connections to any of these during runtime, something is wrong:

❌ analytics.google.com  
❌ mixpanel.com  
❌ segment.com  
❌ amplitude.com  
❌ Any domain not your LLM provider

**What to do if you see unexpected connections:**
1. Stop using the tool immediately
2. Report the issue at https://github.com/mannyluvstacos/PocketCode/issues
3. Run `netstat -tulpn` to identify the process making the connection

## Verification Checklist

Use this checklist to verify PocketCode's network behavior:

- [ ] Read through setup.sh source code
- [ ] Confirm only 2 curl commands (Node.js + OpenCode)
- [ ] Monitor network during setup (see official repos only)
- [ ] Monitor network during OpenCode usage
- [ ] Confirm only LLM provider API is contacted
- [ ] Check OpenCode config file
- [ ] Verify API endpoint is your LLM provider
- [ ] No analytics endpoints in config
- [ ] Test with firewall blocking all but LLM provider
- [ ] OpenCode still works (proves only connects to provider)

## Advanced: Packet Inspection

For ultimate verification, inspect actual packets:

```bash
# Capture packets (requires root or PCAPdroid)
tcpdump -i any -w capture.pcap

# Use OpenCode for a few prompts

# Stop capture

# Analyze with Wireshark or tshark
tshark -r capture.pcap -Y "http or tls" -T fields -e http.host -e tls.handshake.extensions_server_name
```

**What you should see:**
- TLS connections to api.openai.com (or your LLM provider)
- HTTP/HTTPS requests to your LLM provider's API
- **No other HTTP/HTTPS traffic from OpenCode process**

## Automated Verification Script

We provide a verification script you can run:

```bash
# Download the verification script
curl -sL https://raw.githubusercontent.com/mannyluvstacos/PocketCode/main/verify_network.sh | bash

# Or run it manually after cloning the repo
./verify_network.sh
```

This script will:
1. Check setup.sh for unexpected network calls
2. Monitor a test OpenCode session
3. Report all network destinations
4. Flag any unexpected connections

## Conclusion

PocketCode is designed with privacy in mind:
- ✅ Open source and auditable
- ✅ Minimal network requests (only to official sources)
- ✅ Runtime communication ONLY with your authenticated LLM provider
- ✅ No telemetry, analytics, or tracking
- ✅ You can verify all of this yourself

If you have concerns or questions, please open an issue at:  
https://github.com/mannyluvstacos/PocketCode/issues

## Additional Resources

- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed architecture and security model
- [OpenCode Documentation](https://opencode.ai/docs) - OpenCode's network behavior
- [Termux Security Model](https://wiki.termux.com/wiki/Main_Page) - How Termux sandboxing works
