# Puente de memoria: Obsidian (VPS) ⇄ GitHub ⇄ Claude Code (celular)

Sincroniza tu **memoria/wiki de Obsidian** alojada en tu VPS de Hostinger con un
**repositorio privado de GitHub**, para poder abrirla desde la **app de Claude Code
en la nube** (celular) con **acceso completo a tu memoria**.

## ¿Por qué así y no conexión directa al VPS?

La app de Claude Code en la nube tiene una **lista blanca de red**: solo puede salir
por HTTPS hacia **GitHub** y repositorios de paquetes. **No puede conectarse a tu VPS**
ni por SSH (puerto 22 bloqueado) ni por HTTPS a tu dominio (da error 403). Se comprobó.

Por eso usamos GitHub como **puente**: tu VPS sigue siendo el dueño de la memoria y la
empuja a un repo privado; la app abre ese repo. Sigue siendo una conexión **HTTPS**,
solo que el intermediario permitido es GitHub.

```
   VPS (Hostinger)              GitHub (repo privado)          Claude Code nube
   ┌────────────────┐  push/pull  ┌──────────────┐   clone/push  ┌──────────────┐
   │ Obsidian vault │ ──────────► │  tu memoria  │ ◄──────────── │  tu celular  │
   │  (markdown)    │ ◄────────── │   (git)      │ ────────────► │              │
   └────────────────┘             └──────────────┘               └──────────────┘
        memory-sync.sh / timer            (bidireccional)
```

## Preparación (una sola vez)

### 1. Crea un repo privado en GitHub
Desde la web o app de GitHub: **New repository** → nombre p.ej. `memoria` →
**Private** → **sin** README/gitignore (vacío) → Create.

### 2. Crea un token de acceso (fine-grained, recomendado)
GitHub → **Settings → Developer settings → Personal access tokens → Fine-grained tokens**
→ **Generate new token**:
- **Repository access**: *Only select repositories* → tu repo `memoria`.
- **Permissions → Repository → Contents**: **Read and write**.
- Copia el token (empieza por `github_pat_...`). Se guardará en el VPS con permisos 600.

### 3. En el VPS, prepara la configuración
```bash
# Clona/copia este repo en el VPS y entra en la carpeta:
cd memory-sync
cp config.example.sh config.sh
nano config.sh   # rellena VAULT_DIR, GITHUB_REPO_URL, GITHUB_USER y GITHUB_TOKEN
```

### 4. Lanza el setup
```bash
./setup-memory-sync.sh
```
Esto convierte tu vault en repo Git, añade `.gitignore`/`.gitattributes` adecuados,
guarda el token de forma segura y hace el primer push a GitHub.

## Sincronización automática (elige una)

**Opción 1 — Timer de systemd (recomendado, cada 5 min):**
```bash
./install-timer.sh
```

**Opción 2 — Cron (cada 5 min):**
```bash
crontab -e
# añade esta línea (ajusta la ruta):
*/5 * * * * /usr/bin/env bash /ruta/a/memory-sync/memory-sync.sh >> ~/memory-sync.log 2>&1
```

**Opción 3 — Tiempo casi real (al guardar):**
```bash
sudo apt-get install -y inotify-tools
./memory-watch.sh    # déjalo corriendo (o dentro de tmux)
```

## Uso desde el celular

1. Abre la **app de Claude Code** → **Nueva sesión**.
2. Elige tu repo privado **`memoria`**.
3. Listo: Claude ya ve **toda tu memoria**. Puedes leer, buscar y editar notas.
4. Si Claude edita algo y hace commit/push, tu VPS lo **baja solo** en la próxima
   sincronización (es bidireccional).

## Detalles importantes

- **Sin conflictos molestos:** los `.md` usan fusión `union` (`.gitattributes`), así
  que editar la misma nota en el VPS y en la nube **no bloquea**: conserva ambos lados.
- **Seguridad:** el token vive solo en el VPS (`~/.git-credentials`, permisos 600) y
  `config.sh` está en `.gitignore`. Nunca se sube al repo. Usa un token *fine-grained*
  limitado a ese único repo.
- **Privacidad:** el repo debe ser **privado**. Tu memoria queda en GitHub (cifrado en
  tránsito y en reposo), no pública.
- **Idempotente:** `memory-sync.sh` se puede correr mil veces sin romper nada.

## Solución de problemas

| Síntoma | Qué mirar |
|--------|-----------|
| `No pude contactar con GitHub` | Token válido y con permiso Contents R/W; red del VPS. |
| `Conflicto de fusión (no-markdown)` | Un archivo binario chocó; resuélvelo con `git status` en el vault. |
| El timer no corre sin sesión | `sudo loginctl enable-linger $USER` |
| Ver logs del timer | `journalctl --user -u memory-sync.service -n 30` |
