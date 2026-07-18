# Configuración de VPS (Hostinger) como entorno de trabajo

Scripts reproducibles para convertir un VPS **Ubuntu/Debian recién creado** en un
entorno de desarrollo seguro y listo para trabajar (incluido **Claude Code**).

## ⚠️ Importante: por qué se hace con scripts y no "en vivo"

Este repositorio nació en una sesión de **Claude Code en la nube**, cuyo entorno
**solo permite salida HTTPS (puerto 443)**. La **salida SSH (puerto 22) está
bloqueada** por la política de red, así que **no es posible que Claude se conecte
directamente a tu VPS desde ahí**.

La solución es mejor a efectos prácticos: en vez de configurar el servidor a mano,
estos scripts dejan la configuración **versionada en Git**. La ejecutas **tú, una
vez, en el VPS**, y puedes reusarla o rehacer el servidor cuando quieras.

## Requisitos

- Un VPS con **Ubuntu 22.04/24.04** o **Debian 11/12** (recién creado).
- Acceso por **clave SSH** al VPS (ya lo tienes).
- Docker (opcional; en tu servidor **ya está instalado**, el script solo lo configura).

## Cómo usarlo

Conéctate a tu VPS por SSH desde tu ordenador, **o** usa el **Terminal del navegador**
que ofrece el panel de Hostinger. Luego:

```bash
# 1. Clona este repositorio en el VPS
git clone <URL-de-este-repo> vps-setup
cd vps-setup

# 2. Copia y edita la configuración (usuario, puerto SSH, zona horaria, etc.)
cp config.example.sh config.sh
nano config.sh

# 3. Ejecuta la comprobación previa (no cambia nada)
bash scripts/00-preflight.sh

# 4. Ejecútalo todo…
./setup.sh

# …o paso a paso (recomendado la primera vez):
./setup.sh 00-preflight
./setup.sh 01-base
./setup.sh 02-security
./setup.sh 03-dev-tools
./setup.sh 04-docker
./setup.sh 05-claude-code
```

## Qué hace cada paso

| Script | Qué hace |
|--------|----------|
| `00-preflight.sh` | Comprueba SO, recursos, claves SSH y conectividad. **No modifica nada.** |
| `01-base.sh` | Actualiza el sistema, crea usuario sudo no-root, paquetes esenciales, zona horaria. |
| `02-security.sh` | Firewall **UFW**, **fail2ban**, actualizaciones automáticas y **endurecido de SSH**. |
| `03-dev-tools.sh` | **Node.js LTS**, git-lfs, Python, tmux, ripgrep y utilidades de desarrollo. |
| `04-docker.sh` | Detecta el Docker existente y añade tu usuario al grupo `docker` (no reinstala). |
| `05-claude-code.sh` | Instala **Claude Code** para tu usuario de trabajo. |

## 🔒 Seguridad del endurecido de SSH (lee esto)

El paso `02-security.sh` deshabilita el **login de root** y la **autenticación por
contraseña** (solo clave SSH). Tiene una red de seguridad:

- **No** se aplica si no detecta una clave SSH válida para tu usuario (evita bloqueos).
- Valida la config con `sshd -t` antes de recargar; si es inválida, **revierte**.
- Tras aplicarlo, **no cierres tu sesión actual**: abre una **sesión nueva** y confirma
  que puedes entrar con tu clave:

  ```bash
  ssh -p <PUERTO_SSH> <TU_USUARIO>@<IP_DE_TU_VPS>
  ```

  Si algo fallara, borra `/etc/ssh/sshd_config.d/99-hardening.conf` y recarga sshd.

> Si cambias el **puerto SSH** en `config.sh`, ábrelo también en el **panel/firewall
> de Hostinger** además del UFW, o perderás el acceso.

## Idempotencia

Los scripts se pueden **volver a ejecutar** sin problemas: detectan lo ya hecho y lo
saltan. Útil para aplicar cambios o recuperar un servidor.
