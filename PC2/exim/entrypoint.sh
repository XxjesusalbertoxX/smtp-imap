#!/bin/bash
set -e

echo "========================================"
echo " Iniciando Exim (PC2)"
echo "========================================"

# ── 1. Crear usuario de correo ────────────────────────────────────────────────
if ! id "${MAIL_USER}" &>/dev/null; then
    echo "[exim] Creando usuario: ${MAIL_USER}"
    adduser -D -h /var/mail/${MAIL_USER} -s /sbin/nologin ${MAIL_USER}
    echo "${MAIL_USER}:${MAIL_PASSWORD}" | chpasswd
else
    echo "[exim] Usuario ${MAIL_USER} ya existe"
fi

# ── 2. Generar exim.conf desde plantilla ─────────────────────────────────────
# exim no soporta envsubst directamente, usamos sed para reemplazar
echo "[exim] Generando exim.conf con dominio: ${MY_DOMAIN}"
sed \
    -e "s|EXIM_MY_DOMAIN|${MY_DOMAIN}|g" \
    -e "s|EXIM_PEER_DOMAIN|${PEER_DOMAIN}|g" \
    -e "s|EXIM_PEER_IP|${PEER_IP}|g" \
    /etc/exim/exim.conf.template > /etc/exim/exim.conf

# ── 3. Sobreescribir el transporte LMTP para usar TCP hacia Dovecot ───────────
# Exim en Alpine usa un conf unico, ajustamos el transporte directamente
cat >> /etc/exim/exim.conf <<EOF

# ---- Transporte LMTP via TCP hacia Dovecot (generado por entrypoint) ----
EOF

# Reemplazar el bloque dovecot_lmtp por uno TCP funcional
python3 - <<'PYEOF'
import re

with open('/etc/exim/exim.conf', 'r') as f:
    content = f.read()

lmtp_block = """dovecot_lmtp:
  driver          = lmtp
  socket          = /dev/null
  # Usamos TCP ya que Dovecot esta en un contenedor separado
  # Se sobreescribe en entrypoint con la config correcta"""

lmtp_tcp = """dovecot_lmtp:
  driver   = smtp
  port     = 24
  protocol = lmtp"""

content = content.replace(lmtp_block, lmtp_tcp)
with open('/etc/exim/exim.conf', 'w') as f:
    f.write(content)
PYEOF

# ── 4. Agregar hosts en /etc/hosts ───────────────────────────────────────────
echo "[exim] Agregando entradas en /etc/hosts"
echo "${MY_IP}    ${MY_DOMAIN}"   >> /etc/hosts
echo "${PEER_IP}  ${PEER_DOMAIN}" >> /etc/hosts

# ── 5. Crear directorio de spool ─────────────────────────────────────────────
mkdir -p /var/spool/exim/input /var/spool/exim/db /var/spool/exim/msglog
chown -R exim:exim /var/spool/exim 2>/dev/null || true

# ── 6. Iniciar Exim en primer plano ──────────────────────────────────────────
echo "[exim] Arrancando exim..."
exec exim -bdf -q30m
