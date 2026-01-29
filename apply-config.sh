#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Load secrets into env
set -a
source ./.env
set +a

# Apply config
cp ./clawdbot.json ~/.clawdbot/clawdbot.json

# Restart gateway to pick up changes
gateway_cmd="moltbot gateway restart"
$gateway_cmd
