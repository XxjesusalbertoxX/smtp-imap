<?php

// =============================================
//  ROUNDCUBE - config.inc.php  (PC2 - Exim)
// =============================================

// ── Servidor IMAP (Dovecot) ───────────────────────────────────────────────────
$config['imap_host'] = 'dovecot:143';

// ── Servidor SMTP (Exim) ──────────────────────────────────────────────────────
$config['smtp_host'] = 'exim:25';
$config['smtp_port'] = 25;
$config['smtp_user'] = '';   // sin autenticacion SMTP (practica LAN)
$config['smtp_pass'] = '';

// ── Clave secreta de sesion (cambiar en produccion) ───────────────────────────
$config['des_key'] = 'practica_smtp_imap_2024_rc';

// ── Nombre del producto ───────────────────────────────────────────────────────
$config['product_name'] = 'Correo Practica - PC2 (Exim)';

// ── Dominio por defecto en el login ──────────────────────────────────────────
// Roundcube agrega @MY_DOMAIN al usuario para formar sebillas@dolly.lat
// Dovecot acepta ambas formas (con y sin dominio)
$config['username_domain'] = getenv('MY_DOMAIN') ?: 'pc2.lab.local';

// ── Plugins habilitados ───────────────────────────────────────────────────────
$config['plugins'] = ['archive', 'zipdownload', 'markasjunk'];

// ── No forzar HTTPS (practica LAN sin certificado) ───────────────────────────
$config['force_https'] = false;
$config['use_https']   = false;

// ── Logs ──────────────────────────────────────────────────────────────────────
$config['log_driver']  = 'stdout';
$config['log_logins']  = true;
$config['debug_level'] = 1;
