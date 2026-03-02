<?php

// =============================================
//  ROUNDCUBE - config.inc.php  (PC2 - Exim)
// =============================================

// ── Servidor IMAP (Dovecot) ───────────────────────────────────────────────────
$config['imap_host'] = 'dovecot:143';

// ── Servidor SMTP (Exim) ──────────────────────────────────────────────────────
$config['smtp_host'] = 'exim:25';
$config['smtp_port'] = 25;
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '%p';

// ── Clave secreta de sesion (cambiar en produccion) ───────────────────────────
$config['des_key'] = 'practica_smtp_imap_2024_rc';

// ── Nombre del producto ───────────────────────────────────────────────────────
$config['product_name'] = 'Correo Practica - PC2 (Exim)';

// ── Dominio por defecto en el login ──────────────────────────────────────────
// Deshabilitado: el usuario escribe solo su nombre (ej: alumno2) sin @dominio
// $config['username_domain'] = '';

// ── Plugins habilitados ───────────────────────────────────────────────────────
$config['plugins'] = ['archive', 'zipdownload', 'markasjunk'];

// ── No forzar HTTPS (practica LAN sin certificado) ───────────────────────────
$config['force_https'] = false;
$config['use_https']   = false;

// ── Logs ──────────────────────────────────────────────────────────────────────
$config['log_driver']  = 'stdout';
$config['log_logins']  = true;
$config['debug_level'] = 1;
