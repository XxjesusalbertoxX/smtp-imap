<?php

// =============================================
//  ROUNDCUBE - config.inc.php  (PC1 - Postfix)
// =============================================

// ── Servidor IMAP (Dovecot) ───────────────────────────────────────────────────
$config['imap_host'] = 'dovecot:143';

// ── Servidor SMTP (Postfix) ───────────────────────────────────────────────────
$config['smtp_host'] = 'postfix:25';
$config['smtp_port'] = 25;
$config['smtp_user'] = '';   // sin autenticacion SMTP (practica LAN)
$config['smtp_pass'] = '';

// ── Clave secreta de sesion (cambiar en produccion) ───────────────────────────
$config['des_key'] = 'practica_smtp_imap_2024_rc';

// ── Nombre del producto ───────────────────────────────────────────────────────
$config['product_name'] = 'Correo Practica - PC1 (Postfix)';

// ── Dominio por defecto en el login ──────────────────────────────────────────
// Roundcube agrega @MY_DOMAIN al usuario para formar jesusin@jesusin.lab.local
// Dovecot acepta ambas formas (con y sin dominio)
$config['username_domain'] = getenv('MY_DOMAIN') ?: 'pc1.lab.local';

// ── Plugins habilitados ───────────────────────────────────────────────────────
$config['plugins'] = ['archive', 'zipdownload', 'markasjunk'];

// ── No forzar HTTPS (practica LAN sin certificado) ───────────────────────────
$config['force_https'] = false;
$config['use_https']   = false;

// ── Logs ──────────────────────────────────────────────────────────────────────
$config['log_driver']  = 'stdout';
$config['log_logins']  = true;
$config['debug_level'] = 1;
