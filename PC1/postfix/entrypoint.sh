#!/bin/bash
set -e

echo "========================================"
echo " Iniciando Postfix (PC1)"
echo "========================================"

# ── 1. Crear usuario de correo ────────────────────────────────────────────────
if ! id "${MAIL_USER}" &>/dev/null; then
    echo "[postfix] Creando usuario: ${MAIL_USER}"
    adduser -D -h /var/mail/${MAIL_USER} -s /sbin/nologin ${MAIL_USER}
    echo "${MAIL_USER}:${MAIL_PASSWORD}" | chpasswd
else
    echo "[postfix] Usuario ${MAIL_USER} ya existe"
fi

# ── 2. Generar main.cf desde plantilla ───────────────────────────────────────
echo "[postfix] Generando main.cf con dominio: ${MY_DOMAIN}"
envsubst '${MY_DOMAIN}' < /etc/postfix/main.cf.template > /etc/postfix/main.cf

# ── 3. Crear tabla de transporte para enrutar al peer ────────────────────────
# Todo correo para PEER_DOMAIN se entrega directamente a PEER_IP puerto 25
echo "[postfix] Configurando transporte hacia ${PEER_DOMAIN} -> ${PEER_IP}"
cat > /etc/postfix/transport <<EOF
${PEER_DOMAIN}    smtp:[${PEER_IP}]:25
EOF
postmap /etc/postfix/transport

# ── 4. Asegurar que /etc/hosts resuelva los dominios ─────────────────────────
echo "[postfix] Agregando entradas en /etc/hosts"
echo "${MY_IP}    ${MY_DOMAIN}"   >> /etc/hosts
echo "${PEER_IP}  ${PEER_DOMAIN}" >> /etc/hosts

# ── 5. Permisos y directorios requeridos por postfix ─────────────────────────
mkdir -p /var/spool/postfix /var/lib/postfix
chown -R postfix:postfix /var/spool/postfix /var/lib/postfix 2>/dev/null || true

# ── 6. Iniciar Postfix en primer plano ───────────────────────────────────────
echo "[postfix] Arrancando postfix..."
exec postfix start-fg
