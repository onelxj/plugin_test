#!/usr/bin/env bash
#
# Reboot plugin installer for Claude Code.
# Usage: curl -fsSL https://reboot.dev/install.sh | bash

set -euo pipefail

BLUE='\033[1;34m'
RED='\033[1;31m'
GREEN='\033[1;32m'
BOLD='\033[1m'
RESET='\033[0m'

log()   { printf "${BLUE}[reboot-plugin]${RESET} %s\n" "$*" >&2; }
error() { printf "${RED}[reboot-plugin] error:${RESET} %s\n" "$*" >&2; }
ok()    { printf "${GREEN}[reboot-plugin]${RESET} %s\n" "$*" >&2; }

# Verify the Claude Code CLI is present before doing anything else.
if ! command -v claude >/dev/null 2>&1; then
    error "Claude Code CLI not found."
    printf >&2 "Install Claude Code and try again:\n"
    printf >&2 "  https://docs.anthropic.com/en/docs/claude-code/setup\n"
    exit 1
fi

# Register the Reboot skills marketplace with Claude Code.
log "Adding Reboot skills marketplace..."
claude plugin marketplace add reboot-dev/reboot-plugin

# Install the plugin from the registered marketplace.
log "Installing reboot plugin..."
claude plugin install reboot@reboot-plugin

# Pre-warm all pinned dependencies by starting a Claude Code session.
# The SessionStart hook fires, adding the plugin's bin/ shims to PATH,
# then Claude invokes them via its bash tool, which triggers
# install_uv.sh, install_node.sh, and install_envoy.sh.
log "Pre-installing dependencies..."
claude -p "Run rbt --version, uv --version, uvx --version, node --version, npm --version, and envoy --version" \
    >/dev/null

ok "Installation complete!"
printf >&2 "\nStart a new Claude Code session, then type ${BOLD}/chat-app${RESET}"
printf >&2 " to build a Reboot AI app.\n"
