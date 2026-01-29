#!/usr/bin/env bash
set -euo pipefail

# macOS launchd user agent for auto-sync + auto-push
PLIST_PATH="$HOME/Library/LaunchAgents/com.moltbot.config-sync-push.plist"
CONFIG_DIR="${MOLTBOT_CONFIG_DIR:-$HOME/moltbot-config}"

cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.moltbot.config-sync-push</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>-lc</string>
    <string>bash "$CONFIG_DIR/sync-config-push.sh"</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StartInterval</key>
  <integer>60</integer>
  <key>StandardOutPath</key>
  <string>$HOME/Library/Logs/moltbot-config-sync-push.log</string>
  <key>StandardErrorPath</key>
  <string>$HOME/Library/Logs/moltbot-config-sync-push.err</string>
</dict>
</plist>
EOF

launchctl unload "$PLIST_PATH" >/dev/null 2>&1 || true
launchctl load "$PLIST_PATH"
launchctl start com.moltbot.config-sync-push

echo "Loaded launchd agent: $PLIST_PATH"