#!/bin/bash

# Usage examples (copy & paste):
#
# 1. Full flow (gets and exports both tokens):
#    source ./scripts/copilot_token_flow.sh --authorize [--copy]
#
# 2. Refresh only the copilot token (default, if no argument):
#    export COPILOT_ACCESS_TOKEN=YOUR_ACCESS_TOKEN
#    source ./scripts/copilot_token_flow.sh [--copy]
#
# 3. Refresh only the copilot token using an argument:
#    source ./scripts/copilot_token_flow.sh --refresh YOUR_ACCESS_TOKEN [--copy]
#
# After any of these commands, you will have in your shell:
#   $COPILOT_ACCESS_TOKEN   and   $COPILOT_TOKEN
# If you use --copy, the copilot token will be copied to your clipboard (if supported).

# set -e

show_help() {
  echo "Usage: $0 [--authorize | --refresh <access_token>] [--copy]"
  echo "  --authorize           Run full Device Flow and get the copilot token."
  echo "  --refresh <token>     Refresh the copilot token using a valid access token (argument or COPILOT_ACCESS_TOKEN env var)."
  echo "  --copy                Copy the copilot token to clipboard if possible."
  echo "  --help                Show this help."
  echo
  echo "By default, if no argument is passed, the script will refresh the copilot token using the COPILOT_ACCESS_TOKEN environment variable."
  echo
  echo "Quick example:"
  echo "  export COPILOT_ACCESS_TOKEN=YOUR_ACCESS_TOKEN"
  echo "  source $0 --copy"
  echo
  echo "NOTE: To persist exported variables in your shell, run the script with:"
  echo "  source $0 ...  or  . $0 ..."
}

obtener_copilot_token() {
  COPILOT_ACCESS_TOKEN="$1"
  COPILOT_COPILOT_RESP=$(curl -s -X GET "https://api.github.com/copilot_internal/v2/token" \
    -H "Authorization: token $COPILOT_ACCESS_TOKEN" \
    -H "User-Agent: GitHubCopilotChat/0.26.7" \
    -H "Editor-Version: vscode/1.99.3" \
    -H "Editor-Plugin-Version: copilot-chat/0.26.7")
  COPILOT_TOKEN=$(echo "$COPILOT_COPILOT_RESP" | jq -r .token)
  if [[ "$COPILOT_TOKEN" == "null" || -z "$COPILOT_TOKEN" ]]; then
    echo "Error: Could not get copilot token. Is the access token valid?" >&2
    return 1
  fi
  echo "Copilot token obtained: $COPILOT_TOKEN"
  # Robust JWT payload decoding
  COPILOT_PAYLOAD_B64=$(echo "$COPILOT_TOKEN" | cut -d '.' -f2)
  # Add padding if needed
  padding=$(( (4 - ${#COPILOT_PAYLOAD_B64} % 4) % 4 ))
  COPILOT_PAYLOAD_B64_PADDED="$COPILOT_PAYLOAD_B64"
  if [ $padding -ne 0 ]; then
    COPILOT_PAYLOAD_B64_PADDED="${COPILOT_PAYLOAD_B64}$(printf '=%.0s' $(seq 1 $padding))"
  fi

  COPILOT_PAYLOAD_RAW=$(echo "$COPILOT_PAYLOAD_B64_PADDED" | base64 -d 2>/dev/null)
  if [ $? -ne 0 ]; then
    echo "Warning: Could not decode JWT payload with base64."
    echo "Raw payload (base64): $COPILOT_PAYLOAD_B64"
  else
    echo "Copilot Token Payload (JWT):"
    echo "$COPILOT_PAYLOAD_RAW" | jq . 2>/dev/null || {
      echo "Warning: JWT payload is not valid JSON and will not be displayed."
    }
  fi
  export COPILOT_TOKEN
  export COPILOT_ACCESS_TOKEN
  echo "Exported variables: COPILOT_TOKEN and COPILOT_ACCESS_TOKEN (if applicable)"

  # Copy to clipboard if requested
  if [[ "$COPILOT_COPY" == "1" ]]; then
    if command -v xclip >/dev/null 2>&1 && [[ -n "$DISPLAY" ]]; then
      echo -n "$COPILOT_TOKEN" | xclip -selection clipboard && echo "Copilot token copied to clipboard (xclip)."
    elif command -v wl-copy >/dev/null 2>&1 && [[ -n "$WAYLAND_DISPLAY" ]]; then
      echo -n "$COPILOT_TOKEN" | wl-copy && echo "Copilot token copied to clipboard (wl-copy)."
    else
      echo "Warning: No clipboard tool found or no graphical session detected."
      echo "Copy this token manually:"
      echo "$COPILOT_TOKEN"
    fi
  fi
}

# Parse --copy flag (can be anywhere)
COPILOT_COPY=0
for arg in "$@"; do
  if [[ "$arg" == "--copy" ]]; then
    COPILOT_COPY=1
    break
  fi
done

# Remove --copy from arguments for logic
ARGS=()
for arg in "$@"; do
  if [[ "$arg" != "--copy" ]]; then
    ARGS+=("$arg")
  fi
done
set -- "${ARGS[@]}"

if [[ "$1" == "--help" ]]; then
  show_help
  return
fi

if [[ "$1" == "--authorize" ]]; then
  # 1. Solicitar device code
  COPILOT_RESP=$(curl -s -X POST "https://github.com/login/device/code" \
    -H "Accept: application/json" \
    -d "client_id=Iv1.b507a08c87ecfe98&scope=read:user,read:org")

  COPILOT_DEVICE_CODE=$(echo "$COPILOT_RESP" | jq -r .device_code)
  COPILOT_USER_CODE=$(echo "$COPILOT_RESP" | jq -r .user_code)
  COPILOT_VERIFICATION_URI=$(echo "$COPILOT_RESP" | jq -r .verification_uri)
  COPILOT_INTERVAL=$(echo "$COPILOT_RESP" | jq -r .interval)

  echo "Open $COPILOT_VERIFICATION_URI and enter the code: $COPILOT_USER_CODE"
  echo "Press Enter after authorizing the device..."
  read

  # 2. Intercambiar device_code por access_token
  while true; do
    COPILOT_TOKEN_RESP=$(curl -s -X POST "https://github.com/login/oauth/access_token" \
      -H "accept: application/json" \
      -H "content-type: application/json" \
      --compressed \
      -d "{\"client_id\":\"Iv1.b507a08c87ecfe98\",\"device_code\":\"$COPILOT_DEVICE_CODE\",\"grant_type\":\"urn:ietf:params:oauth:grant-type:device_code\"}")
    COPILOT_ACCESS_TOKEN=$(echo "$COPILOT_TOKEN_RESP" | jq -r .access_token)
    if [[ "$COPILOT_ACCESS_TOKEN" != "null" ]]; then
      break
    fi
    sleep $COPILOT_INTERVAL
  done

  echo "Access token obtained: $COPILOT_ACCESS_TOKEN"
  obtener_copilot_token "$COPILOT_ACCESS_TOKEN"
  return
fi
# END --authorize

if [[ "$1" == "--refresh" ]]; then
  if [[ -n "$2" ]]; then
    COPILOT_ACCESS_TOKEN="$2"
  elif [[ -n "$COPILOT_ACCESS_TOKEN" ]]; then
    echo "Using COPILOT_ACCESS_TOKEN from environment variable."
  else
    echo "Error: You must provide the access token as an argument or set the COPILOT_ACCESS_TOKEN environment variable."
    show_help
    return
  fi
  obtener_copilot_token "$COPILOT_ACCESS_TOKEN"
  return
fi
# END --refresh

# --- Nuevo comportamiento por defecto: refresco automático ---
if [[ $# -eq 0 ]]; then
  if [[ -n "$COPILOT_ACCESS_TOKEN" ]]; then
    echo "Refreshing copilot token using COPILOT_ACCESS_TOKEN from environment variable..."
    obtener_copilot_token "$COPILOT_ACCESS_TOKEN"
    return
  else
    echo "Error: No access token provided and COPILOT_ACCESS_TOKEN environment variable is not set."
    show_help
    return
  fi
fi
# --- Fin nuevo comportamiento por defecto ---

echo "Unknown argument: $1"
show_help
return

