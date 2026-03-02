#!/bin/bash
set -e

echo "========================================"
echo " Iniciando Dovecot (PC1)"
echo "========================================"

# ── 1. Crear usuario virtual de correo (vmail) ───────────────────────────────
if ! id "vmail" &>/dev/null; then
    echo "[dovecot] Creando usuario del sistema: vmail"
    addgroup -g 5000 vmail
    adduser -D -u 5000 -G vmail -h /var/mail -s /sbin/nologin vmail
fi

# ── 2. Crear maildir del usuario de la practica ──────────────────────────────
echo "[dovecot] Creando maildir para: ${MAIL_USER}"
MAILDIR="/var/mail/${MAIL_USER}/Maildir"
mkdir -p "${MAILDIR}/cur" "${MAILDIR}/new" "${MAILDIR}/tmp"
chown -R vmail:vmail "/var/mail/${MAIL_USER}"

# ── 3. Crear archivo de usuarios para autenticacion ─────────────────────────
# Formato: usuario:{PLAIN}contraseña:uid:gid::/var/mail/usuario::
echo "[dovecot] Registrando usuario ${MAIL_USER} en base de autenticacion"
mkdir -p /etc/dovecot
cat > /etc/dovecot/users <<EOF
${MAIL_USER}:{PLAIN}${MAIL_PASSWORD}:5000:5000::/var/mail/${MAIL_USER}::
EOF
chmod 600 /etc/dovecot/users

# ── 4. Iniciar Dovecot en primer plano ───────────────────────────────────────
echo "[dovecot] Arrancando dovecot..."
exec dovecot -F
