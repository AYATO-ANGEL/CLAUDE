#!/usr/bin/env bash
# config.example.sh — copia este archivo a "config.sh" y ajústalo a tu VPS.
#
#   cp config.example.sh config.sh
#   nano config.sh
#
# config.sh está en .gitignore para que no subas datos de tu servidor al repo.

# Usuario de trabajo (no-root) con permisos sudo.
# Si ya entras con un usuario propio, pon ese nombre y el script lo respeta.
export WORK_USER="deploy"

# Puerto SSH. Déjalo en 22 salvo que quieras cambiarlo (reduce ruido de bots).
# Si lo cambias, ¡acuérdate de abrirlo en el panel/firewall de Hostinger!
export SSH_PORT="22"

# Zona horaria del servidor.
export TIMEZONE="Europe/Madrid"

# Versión de Node.js LTS a instalar (rama mayor). Claude Code necesita >= 18.
export NODE_MAJOR="20"

# Endurecer SSH desactivando login de root y autenticación por contraseña.
# Solo se aplica si el script detecta una clave SSH válida para WORK_USER,
# para no dejarte fuera. Requiere que uses clave SSH (tu caso).
export HARDEN_SSH="1"

# Responder "sí" automáticamente a las confirmaciones (para automatización).
# Déjalo en 0 la primera vez para revisar cada paso.
export ASSUME_YES="0"
