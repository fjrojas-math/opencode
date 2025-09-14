# Copilot Token Flow Scripts

Este directorio contiene dos scripts para obtener y refrescar el token de GitHub Copilot de forma sencilla y compatible con Linux:

- `copilot_token_flow.sh` (Bash, compatible con bash y zsh)
- `copilot_token_flow.py` (Python 3, sin dependencias externas)

---

## Uso rápido (refresco automático)

Si ya tienes un access token de GitHub Copilot, simplemente exporta la variable y ejecuta el script:

### Bash

```bash
export COPILOT_ACCESS_TOKEN=YOUR_ACCESS_TOKEN
source scripts/copilot_token_flow.sh --copy
```

### Python

```bash
export COPILOT_ACCESS_TOKEN=YOUR_ACCESS_TOKEN
python3 scripts/copilot_token_flow.py --copy
```

Esto refrescará el copilot token y lo copiará al portapapeles si tienes `xclip` o `wl-copy` y entorno gráfico.

---

## Flujo completo de autorización (Device Flow)

Si no tienes access token, puedes obtenerlo y refrescar el copilot token en un solo paso:

### Bash

```bash
source scripts/copilot_token_flow.sh --authorize --copy
```

### Python

```bash
python3 scripts/copilot_token_flow.py --authorize --copy
```

Sigue las instrucciones en pantalla: abre la URL, introduce el código, autoriza y presiona Enter. El script mostrará ambos tokens y copiará el copilot token al portapapeles si es posible.

---

## Opciones disponibles

- `--authorize` Ejecuta el flujo completo de autorización Device Flow y obtiene ambos tokens.
- `--refresh <token>` Refresca el copilot token usando un access token (argumento o variable de entorno).
- `--copy` Copia el copilot token al portapapeles si es posible.
- `--help` Muestra la ayuda.

> **Nota:** Si no se pasa ningún argumento, ambos scripts refrescan el copilot token usando la variable de entorno `COPILOT_ACCESS_TOKEN`.

---

## Exportar variables en tu shell

- En bash, si usas `source`, las variables se exportan automáticamente.
- En python, puedes usar:
  ```bash
  eval $(python3 scripts/copilot_token_flow.py --copy)
  ```

---

## Compatibilidad y dependencias

- **Bash:** Requiere `curl`, `jq` y opcionalmente `xclip` o `wl-copy` para copiar al portapapeles.
- **Python:** Solo requiere Python 3 estándar. Para copiar al portapapeles, necesita `xclip` o `wl-copy` y entorno gráfico.
- Ambos scripts funcionan en Linux estándar y son compatibles con bash y zsh.

---

## Ejemplo de salida

```
Copilot token obtenido: ghc_xxx...
Payload del Copilot Token (JWT):
{
  "exp": 1700000000,
  ...
}
Variables exportadas: COPILOT_TOKEN y COPILOT_ACCESS_TOKEN (si aplica)
Copilot token copied to clipboard (xclip).
```

---

¿Dudas o problemas? Abre un issue o revisa la ayuda de cada script con `--help`.
