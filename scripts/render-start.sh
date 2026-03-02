#!/bin/sh
set -eu

PORT="${PORT:-4200}"
DATA_HOME="${OPENFANG_DATA_HOME:-/data}"

export HOME="$DATA_HOME"
OPENFANG_DIR="$HOME/.openfang"
CONFIG_PATH="$OPENFANG_DIR/config.toml"

mkdir -p "$OPENFANG_DIR"

DEFAULT_PROVIDER="${DEFAULT_MODEL_PROVIDER:-anthropic}"
DEFAULT_MODEL="${DEFAULT_MODEL_NAME:-claude-3-5-sonnet-20241022}"
DEFAULT_API_KEY_ENV="${DEFAULT_MODEL_API_KEY_ENV:-}"
DEFAULT_BASE_URL="${DEFAULT_MODEL_BASE_URL:-}"

if [ ! -f "$CONFIG_PATH" ]; then
  {
    echo "api_listen = \"0.0.0.0:${PORT}\""
    echo
    echo "[default_model]"
    echo "provider = \"${DEFAULT_PROVIDER}\""
    echo "model = \"${DEFAULT_MODEL}\""
    echo "api_key_env = \"${DEFAULT_API_KEY_ENV}\""
    if [ -n "$DEFAULT_BASE_URL" ]; then
      echo "base_url = \"${DEFAULT_BASE_URL}\""
    fi
  } > "$CONFIG_PATH"
else
  if grep -q '^api_listen\s*=' "$CONFIG_PATH"; then
    sed -i "s|^api_listen\s*=.*|api_listen = \"0.0.0.0:${PORT}\"|" "$CONFIG_PATH"
  else
    TMP_PATH="${CONFIG_PATH}.tmp"
    {
      echo "api_listen = \"0.0.0.0:${PORT}\""
      echo
      cat "$CONFIG_PATH"
    } > "$TMP_PATH"
    mv "$TMP_PATH" "$CONFIG_PATH"
  fi
fi

exec /usr/local/bin/openfang start
