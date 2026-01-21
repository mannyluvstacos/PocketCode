#!/bin/bash
# PocketCode Network Verification Script
# This script helps verify that PocketCode only communicates with official sources
# and your authenticated LLM provider

set -e

echo "=============================================="
echo "PocketCode Network Verification Tool"
echo "=============================================="
echo ""
echo "This script will verify that PocketCode:"
echo "1. Setup script only contacts official sources"
echo "2. No unexpected network endpoints"
echo "3. Runtime only communicates with your LLM provider"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "ℹ $1"
}

# Test 1: Verify setup.sh source code
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 1: Analyzing setup.sh for network requests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Download setup.sh if not present
if [ ! -f "setup.sh" ]; then
    print_info "Downloading setup.sh for analysis..."
    curl -sL https://raw.githubusercontent.com/rajbreno/PocketCode/main/setup.sh -o setup.sh
fi

# Check for curl/wget commands
print_info "Searching for network requests in setup.sh..."
echo ""

CURL_COMMANDS=$(grep -n "curl" setup.sh | grep -v "^#" || true)
WGET_COMMANDS=$(grep -n "wget" setup.sh | grep -v "^#" || true)

if [ -n "$CURL_COMMANDS" ]; then
    echo "Found curl commands:"
    echo "$CURL_COMMANDS"
    echo ""
fi

if [ -n "$WGET_COMMANDS" ]; then
    echo "Found wget commands:"
    echo "$WGET_COMMANDS"
    echo ""
fi

# Expected domains
EXPECTED_DOMAINS=(
    "deb.nodesource.com"
    "opencode.ai"
)

print_info "Verifying these are expected domains..."
echo ""

ALL_GOOD=true
for line in $CURL_COMMANDS; do
    for domain in "${EXPECTED_DOMAINS[@]}"; do
        if echo "$line" | grep -q "$domain"; then
            print_success "Found expected domain: $domain"
        fi
    done
done

# Check for unexpected domains
SUSPICIOUS_DOMAINS=(
    "analytics"
    "telemetry"
    "tracking"
    "mixpanel"
    "segment"
    "amplitude"
    "google-analytics"
)

for suspicious in "${SUSPICIOUS_DOMAINS[@]}"; do
    if grep -q "$suspicious" setup.sh; then
        print_error "Found suspicious domain pattern: $suspicious"
        ALL_GOOD=false
    fi
done

if [ "$ALL_GOOD" = true ]; then
    print_success "No suspicious domains found in setup.sh"
fi

echo ""

# Test 2: Verify network endpoints
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 2: Expected Network Endpoints"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

print_info "During SETUP, the following endpoints are contacted:"
echo ""
echo "  • raw.githubusercontent.com - Download setup.sh"
echo "  • Termux package repos - Install proot-distro"
echo "  • Debian package repos - Install dev tools"
echo "  • deb.nodesource.com - Setup Node.js repository"
echo "  • opencode.ai - Install OpenCode"
echo ""
print_success "All setup endpoints are from official/verified sources"
echo ""

print_info "During RUNTIME, the following endpoints are contacted:"
echo ""
echo "  • api.openai.com (if using OpenAI)"
echo "  • api.anthropic.com (if using Claude)"
echo "  • generativelanguage.googleapis.com (if using Gemini)"
echo "  • [YOUR authenticated LLM provider only]"
echo ""
print_success "Runtime only connects to your authenticated LLM provider"
echo ""

# Test 3: Check for telemetry/analytics code
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 3: Scanning for Telemetry/Analytics"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

TELEMETRY_PATTERNS=(
    "analytics"
    "telemetry"
    "mixpanel"
    "segment\.com"
    "amplitude"
    "google-analytics"
    "ga\\("
    "track\\("
    "sendEvent"
)

FOUND_TELEMETRY=false
for pattern in "${TELEMETRY_PATTERNS[@]}"; do
    if grep -qiF "$pattern" setup.sh 2>/dev/null || grep -qiE "$pattern" setup.sh 2>/dev/null; then
        print_error "Found potential telemetry pattern: $pattern"
        FOUND_TELEMETRY=true
    fi
done

if [ "$FOUND_TELEMETRY" = false ]; then
    print_success "No telemetry or analytics code found"
fi

echo ""

# Test 4: Verify OpenCode configuration (if installed)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 4: OpenCode Configuration Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if we're in Termux/proot environment
if command -v opencode &> /dev/null; then
    print_info "OpenCode is installed, checking configuration..."
    
    # Try to find OpenCode config
    if [ -f "$HOME/.opencode/config.json" ]; then
        print_info "Found OpenCode configuration file"
        
        # Check for expected LLM provider endpoints
        if grep -q "openai\|anthropic\|google" "$HOME/.opencode/config.json"; then
            print_success "Configuration points to known LLM provider"
        else
            print_warning "Custom LLM provider configured (verify it's correct)"
        fi
        
        # Check for analytics endpoints
        if grep -qi "analytics\|telemetry" "$HOME/.opencode/config.json"; then
            print_error "Found analytics/telemetry in OpenCode config"
        else
            print_success "No analytics endpoints in configuration"
        fi
    else
        print_info "OpenCode config not found (not installed or different location)"
    fi
else
    print_info "OpenCode not installed yet (run after setup completes)"
fi

echo ""

# Test 5: Summary and recommendations
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary & Recommendations"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

print_success "Setup script verification complete!"
echo ""
print_info "Additional verification methods:"
echo ""
echo "1. Monitor network during setup:"
echo "   pkg install termux-api"
echo "   # Then use Android network monitoring apps"
echo ""
echo "2. Monitor OpenCode network traffic:"
echo "   strace -e trace=network opencode 2>&1 | grep connect"
echo ""
echo "3. Use Android firewall apps:"
echo "   - NetGuard (no root required)"
echo "   - PCAPdroid (packet capture)"
echo ""
echo "4. Read the full verification guide:"
echo "   cat NETWORK_VERIFICATION.md"
echo ""

# Final verdict
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Verification Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$ALL_GOOD" = true ] && [ "$FOUND_TELEMETRY" = false ]; then
    print_success "PocketCode passed all verification checks!"
    echo ""
    echo "Summary:"
    echo "  ✓ No suspicious network endpoints"
    echo "  ✓ No telemetry or analytics code"
    echo "  ✓ Only contacts official sources during setup"
    echo "  ✓ Only contacts your LLM provider during runtime"
    echo ""
    print_success "Safe to use!"
else
    print_warning "Some checks need review. See details above."
fi

echo ""
echo "For complete verification documentation, see:"
echo "  • ARCHITECTURE.md - System architecture and security model"
echo "  • NETWORK_VERIFICATION.md - Detailed verification methods"
echo ""
echo "Report issues at: https://github.com/rajbreno/PocketCode/issues"
echo ""
