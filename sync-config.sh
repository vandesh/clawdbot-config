#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${MOLTBOT_CONFIG_DIR:-$HOME/moltbot-config}"
ENV_FILE="${MOLTBOT_ENV_FILE:-$CONFIG_DIR/.env}"
SRC="${MOLTBOT_CONFIG_SRC:-$HOME/.clawdbot/clawdbot.json}"
DST="$CONFIG_DIR/clawdbot.json"

if [[ ! -f "$SRC" ]]; then
  echo "Source config not found: $SRC" >&2
  exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Env file not found: $ENV_FILE" >&2
  exit 1
fi

TMP="$(mktemp)"
cp "$SRC" "$TMP"

# Load env for replacement values
set -a
source "$ENV_FILE"
set +a

# Replace secret values with ${VAR} placeholders
while IFS='=' read -r key val; do
  [[ -z "$key" ]] && continue
  [[ "$key" =~ ^# ]] && continue
  [[ -z "$val" ]] && continue
  esc_val=$(printf '%s' "$val" | sed -e 's/[\/&]/\\&/g')
  sed -i "s/$esc_val/\${$key}/g" "$TMP"
done < "$ENV_FILE"

# Only commit if config changed
if ! cmp -s "$TMP" "$DST"; then
  mv "$TMP" "$DST"
  cd "$CONFIG_DIR"
  git add clawdbot.json
  git commit -m "Sync moltbot config" >/dev/null 2>&1 || true
else
  rm -f "$TMP"
fi
