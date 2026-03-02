<?php

// =============================================
//  ROUNDCUBE - config.inc.php  (PC1 - Postfix)
// =============================================

// Base de datos SQLite (no requiere contenedor extra)
$config['db_dsnw'] = 'sqlite:////var/roundcube/db/roundcube.db?mode=0640';

// ── Servidor IMAP (Dovecot) ───────────────────────────────────────────────────
$config['imap_host'] = 'dovecot:143';

// ── Servidor SMTP (Postfix) ───────────────────────────────────────────────────
$config['smtp_host'] = 'postfix:25';
$config['smtp_port'] = 25;
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '%p';

// ── Clave secreta de sesion (cambiar en produccion) ───────────────────────────
$config['des_key'] = 'practica_smtp_imap_2024_rc';

// ── Nombre del producto ───────────────────────────────────────────────────────
$config['product_name'] = 'Correo Practica - PC1 (Postfix)';

// ── Dominio por defecto en el login ──────────────────────────────────────────
// Se inyecta via variable de entorno ROUNDCUBE_DEFAULT_HOST en el compose
// y se puede sobreescribir aqui si se desea hardcodearlo
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
