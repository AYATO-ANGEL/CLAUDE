# CLAUDE.md — Arranque de Ángel para Claude Code en la NUBE (web/celular)

> ⚠️ Este archivo **no es** el manual. El manual operativo **canónico** de Ángel vive
> en Google Drive: **`03-ANGEL/AGENTS.md`** (una sola fuente de verdad — no duplicar).
> Este archivo solo **arranca** el contexto cuando Claude Code corre en la **nube**
> (claude.ai/code o la app del celular), donde no existen ni el comando `memoria`,
> ni Syncthing, ni Tailscale, ni el disco `D:` — eso es el VPS/PC, no la nube.

## Paso 0 — OBLIGATORIO al iniciar la sesión

Antes de responder cualquier cosa sobre archivos, memoria, proyectos o estado, **lee
el manual canónico desde Google Drive** con las herramientas MCP de Drive:

- Manual canónico: **`03-ANGEL/AGENTS.md`** — Drive fileId `1LUk6JpiIljeit4V0b2k0eSJ8dzcIXcZJ`
  (carpeta `03-ANGEL` = `14cK9UOodggXgxUra6P94yNmyIhJz1TvJ`).
- Estado rápido de la memoria (0 tokens de cómputo pesado): **`MEMORIA-ESTADO.md`**
  — fileId `1P-mvwtSC-VsWNbrIjC-i-bHUy96vsNCm`.

Si los fileId cambiaron, búscalos por nombre con `search_files`
(`title = 'AGENTS.md' and '14cK9UOodggXgxUra6P94yNmyIhJz1TvJ' in parents`).

## Acceder a la Wiki / memoria DESDE LA NUBE

- Toda la memoria y la Wiki están en Drive, en **`03-ANGEL/00-IA/08-MEMORIA/`**
  (folder `11-4sc_tpATCMJk1PMPLyqkha8t-UqxHw`) y el vault Obsidian "Segundo Cerebro".
- Úsalas con **Google Drive MCP** (`search_files`, `read_file_content`,
  `get_file_metadata`). Aquí NO corras `memoria buscar` ni `graphify` (son del VPS).
- Manual del VPS (por si preguntan): `03-ANGEL/00-IA/03-VPS/` (`AGENTS.md` + `MEMORY.md`).
- 🔒 Los archivos **`.c9r` (Cryptomator)** están **cifrados**: no se pueden leer aquí.
  Los casos delicados (§3c del manual) viven solo dentro de esa bóveda.

## Reglas de oro (resumen — el detalle está en el AGENTS.md canónico)

- **Cuestionar primero, no validar por defecto.** Si algo no cuadra, dilo antes de actuar.
- **Confirmar siempre antes de borrar o de cambios destructivos.**
- **Explorar → proponer plan en TABLA → OK de Ángel → ejecutar → reportar.**
- Respuestas con **tablas, diagramas de texto y ejemplos visuales**, nivel básico, sin jerga.
- **Al inicio, declara en 1 línea el modelo** que conviene (Opus = bisturí: solo
  decisión/síntesis/redacción fina; para lo demás, avisar de bajar a Sonnet con `/model`).

## Qué es esta "nube" dentro del sistema de Ángel

Es una **4ª superficie** junto al VPS, la PC y las extensiones. Corre en servidores de
Anthropic, atada a este repo de GitHub, y **no llega al VPS** (SSH y dominios propios
bloqueados por su política de red). Su súperpoder aquí es el **acceso directo a Drive**,
donde ya vive toda la Wiki sincronizada.
