#!/bin/bash

# Usage examples (copy & paste):
#
# 1. Full flow (gets and exports both tokens):
#    source ./scripts/copilot_token_flow.sh --authorize
#
# 2. Refresh only the copilot token using an argument:
#    source ./scripts/copilot_token_flow.sh --refresh YOUR_ACCESS_TOKEN
#
# 3. Refresh only the copilot token using an environment variable:
#    export COPILOT_ACCESS_TOKEN=YOUR_ACCESS_TOKEN
#    source ./scripts/copilot_token_flow.sh --refresh
#
# After any of these commands, you will have in your shell:
#   $COPILOT_ACCESS_TOKEN   and   $COPILOT_TOKEN

# set -e

show_help() {
  echo "Uso: $0 [--authorize | --refresh <access_token>]"
  echo "  --authorize           Ejecuta el flujo completo de autorización Device Flow y obtiene el copilot token."
  echo "  --refresh <token>     Refresca el copilot token usando un access token válido (argumento o variable COPILOT_ACCESS_TOKEN)."
  echo "  --help                Muestra esta ayuda."
  echo
  echo "NOTA: Para que las variables exportadas persistan en tu shell, ejecuta el script con:"
  echo "  source $0 ...  o  . $0 ..."
}

obtener_copilot_token() {
  COPILOT_ACCESS_TOKEN="$1"
  COPILOT_COPILOT_RESP=$(curl -s -X GET "https://api.github.com/copilot_internal/v2/token" \
    -H "Authorization: token $COPILOT_ACCESS_TOKEN")
  COPILOT_TOKEN=$(echo "$COPILOT_COPILOT_RESP" | jq -r .token)
  if [[ "$COPILOT_TOKEN" == "null" || -z "$COPILOT_TOKEN" ]]; then
    echo "Error: No se pudo obtener el copilot token. ¿El access token es válido?" >&2
    return 1
  fi
  echo "Copilot token obtenido: $COPILOT_TOKEN"
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
    echo "Payload del Copilot Token (JWT):"
    echo "$COPILOT_PAYLOAD_RAW" | jq . 2>/dev/null || {
      echo "Warning: Could not parse payload as JSON. Raw payload:"
      echo "$COPILOT_PAYLOAD_RAW"
    }
  fi
  export COPILOT_TOKEN
  export COPILOT_ACCESS_TOKEN
  echo "Variables exportadas: COPILOT_TOKEN y COPILOT_ACCESS_TOKEN (si aplica)"
}

if [[ $# -eq 0 || "$1" == "--help" ]]; then
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

  echo "Abre $COPILOT_VERIFICATION_URI e introduce el código: $COPILOT_USER_CODE"
  read -p "Presiona Enter cuando hayas autorizado el dispositivo..."

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

  echo "Access token obtenido: $COPILOT_ACCESS_TOKEN"
  obtener_copilot_token "$COPILOT_ACCESS_TOKEN"
  return
fi
# END --authorize

if [[ "$1" == "--refresh" ]]; then
  if [[ -n "$2" ]]; then
    COPILOT_ACCESS_TOKEN="$2"
  elif [[ -n "$COPILOT_ACCESS_TOKEN" ]]; then
    echo "Usando COPILOT_ACCESS_TOKEN de variable de entorno."
  else
    echo "Error: Debes proporcionar el access token como argumento o definir la variable de entorno COPILOT_ACCESS_TOKEN."
    show_help
    return
  fi
  obtener_copilot_token "$COPILOT_ACCESS_TOKEN"
  return
fi
# END --refresh

echo "Argumento no reconocido: $1"
show_help
return
