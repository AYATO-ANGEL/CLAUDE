# Trabajar con el VPS desde el celular — nota de sesión

> El VPS de Ángel (`angelayato.tech`, Hostinger) **ya está armado y operativo** desde
> el 13-07-2026: Claude Code, memoria sincronizada (Syncthing), Drive (rclone),
> Tailscale, backups y alertas. El manual completo vive en Google Drive:
> `03-ANGEL/00-IA/03-VPS/` (`AGENTS.md` + `MEMORY.md` + diagrama).
>
> Esta rama empezó para "configurar el VPS", pero resultó que ya estaba todo hecho.
> Lo único que se conserva aquí es lo **nuevo y útil** que salió de la sesión:
> **Remote Control**.

## Remote Control: manejar el Claude Code del VPS desde la app nativa

Hoy usas el VPS desde el celular con **Termius** (terminal). Remote Control te deja
manejar **ese mismo Claude Code que corre en el VPS** desde la **app de Claude**
(interfaz nativa), con el mismo acceso total a tu memoria.

Pasos (se corren en el VPS por Termius):

| Paso | Comando | Para qué |
|---|---|---|
| 1 | `npm update -g @anthropic-ai/claude-code` | Versión reciente (Remote Control es nuevo) |
| 2 | `tmux new -s rc` | Sesión persistente (ya tienes `linger` activo) |
| 3 | `cd /opt/obsidian/vault` | Ir donde vive la memoria (o `/opt/memoria`, `/mnt/gdrive`) |
| 4 | `claude --remote-control "VPS Ángel"` | Arranca Claude con Remote Control |
| 5 | `Ctrl+b` y luego `d` | Salir de tmux; la sesión sigue viva |

En el celular: **app de Claude → Código** → aparece la sesión **"VPS Ángel"**
(ícono de computadora, punto verde). La manejas desde ahí; Claude corre en el VPS.

**Notas:**
- Mismo plan Pro y mismo contexto (el hook `memoria mapa` y `AGENTS.md` se cargan solos).
- Si la red se cae >10 min, la sesión termina → repetir el paso 4.
- Privacidad: Remote Control guarda el transcript en servidores de Anthropic para
  sincronizar entre dispositivos. Tenlo en cuenta para casos delicados (§3c: bóveda
  Cryptomator, legal/bancario).
- Requisitos ya cumplidos: login claude.ai (OAuth), `api.anthropic.com`, tmux + linger.

> Al usarlo, actualizar la bitácora `03-VPS/MEMORY.md` en Drive (fecha + qué se hizo),
> como manda el protocolo del sistema.
