# Practica: Servidor de Correo con SMTP e IMAP

## Descripcion General

En esta practica levantaran un servidor de correo electronico completo usando
**Docker** sobre **Rocky Linux 9**. Trabajaran en parejas: cada integrante
levanta su propia pila de servicios y al final podran enviarse correos entre
ambas PCs usando la interfaz web **Roundcube**.

```
┌─────────────────────────────┐         ┌─────────────────────────────┐
│           PC1               │         │           PC2               │
│                             │         │                             │
│  ┌────────────────────────┐ │  SMTP   │ ┌────────────────────────┐ │
│  │   Roundcube (Web :80)  │ │ ──────► │ │   Roundcube (Web :80)  │ │
│  └────────────────────────┘ │         │ └────────────────────────┘ │
│  ┌────────────────────────┐ │         │ ┌────────────────────────┐ │
│  │   Postfix  (SMTP :25)  │ │◄─────── │ │    Exim    (SMTP :25)  │ │
│  └────────────────────────┘ │         │ └────────────────────────┘ │
│  ┌────────────────────────┐ │         │ ┌────────────────────────┐ │
│  │   Dovecot  (IMAP :143) │ │         │ │   Dovecot  (IMAP :143) │ │
│  └────────────────────────┘ │         │ └────────────────────────┘ │
└─────────────────────────────┘         └─────────────────────────────┘
```

| PC  | Servidor SMTP | Servidor IMAP | Interfaz Web |
|-----|--------------|---------------|-------------|
| PC1 | Postfix      | Dovecot       | Roundcube   |
| PC2 | Exim         | Dovecot       | Roundcube   |

> **Nota sobre puertos:** Todos los alumnos usan los mismos puertos (25, 143, 80).
> Esto no genera conflicto porque cada VM tiene su propia IP en la red local.
> El problema de puertos duplicados solo existe cuando se quiere salir a internet,
> lo cual no es el caso de esta practica.

---

## Estructura del Repositorio

```
smtp-imap/
├── README.md
├── .gitignore
├── PC1/                        ← Postfix + Dovecot + Roundcube
│   ├── .env.example            ← Plantilla de configuracion
│   ├── docker-compose.yml
│   ├── postfix/
│   │   ├── Dockerfile
│   │   ├── main.cf
│   │   └── entrypoint.sh
│   ├── dovecot/
│   │   ├── Dockerfile
│   │   ├── dovecot.conf
│   │   └── entrypoint.sh
│   └── roundcube/
│       └── config.inc.php
└── PC2/                        ← Exim + Dovecot + Roundcube
    ├── .env.example
    ├── docker-compose.yml
    ├── exim/
    │   ├── Dockerfile
    │   ├── exim4.conf
    │   └── entrypoint.sh
    ├── dovecot/
    │   ├── Dockerfile
    │   ├── dovecot.conf
    │   └── entrypoint.sh
    └── roundcube/
        └── config.inc.php
```

---

## Parte 1 — Prerrequisitos

### 1.1 Verificar conectividad entre PCs

Antes de comenzar, confirmen que sus VMs se pueden ver entre si.
Primero obtengan su IP:

```bash
ip addr show | grep "inet "
```

Busca la linea que empiece con `inet` y tenga una IP tipo `192.168.x.x`.
Anota esa IP, la necesitaras para el archivo `.env`.

Luego haz ping hacia la PC de tu compañero para confirmar conectividad:

```bash
ping -c 4 <IP_del_compañero>
```

Si el ping responde, pueden continuar. Si no responde, revisen que ambas VMs
esten en la misma red en VirtualBox (modo **Red Interna** o **Solo Anfitrion**
segun lo haya configurado el profesor).

---

## Parte 2 — Instalacion de Docker en Rocky Linux 9

Ejecuten estos comandos **en ambas PCs**. Solo necesitan hacerlo una vez.

### 2.1 Actualizar el sistema

```bash
sudo dnf update -y
```

### 2.2 Instalar dependencias base

```bash
sudo dnf install -y dnf-plugins-core curl git
```

### 2.3 Agregar el repositorio oficial de Docker

```bash
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

### 2.4 Instalar Docker y el plugin de Compose

```bash
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

### 2.5 Iniciar Docker y habilitarlo para que arranque con el sistema

```bash
sudo systemctl enable --now docker
```

Verificar que este corriendo:

```bash
sudo systemctl status docker
```

Deberias ver `Active: active (running)`.

### 2.6 Agregar tu usuario al grupo docker

Esto evita tener que escribir `sudo` en cada comando de Docker:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Verifica que funciona sin sudo:

```bash
docker version
```

---

## Parte 3 — Clonar el Repositorio

```bash
git clone <URL_DEL_REPOSITORIO>
cd smtp-imap
```

> Reemplaza `<URL_DEL_REPOSITORIO>` con la URL que te proporcione el profesor.

---

## Parte 4 — Configurar el Archivo .env

Esta es la unica parte donde **cada alumno pone sus propios datos**.
El archivo `.env` le dice a los contenedores quien eres tu y quien es tu compañero.

### PC1 — Configurar .env

```bash
cd PC1
cp .env.example .env
nano .env
```

Edita cada variable segun tu situacion:

```env
# Tu IP (la que obtuviste en el paso 1.1)
MY_IP=192.168.1.10

# Tu dominio falso (coordinalo con tu compañero, deben ser distintos)
MY_DOMAIN=pc1.lab.local

# IP de tu compañero
PEER_IP=192.168.1.20

# Dominio falso de tu compañero
PEER_DOMAIN=pc2.lab.local

# Nombre de usuario con el que entrarás a Roundcube
MAIL_USER=alumno1

# Contraseña para ese usuario
MAIL_PASSWORD=mipass123
```

Guarda con `Ctrl+O`, `Enter`, y cierra con `Ctrl+X`.

### PC2 — Configurar .env

```bash
cd PC2
cp .env.example .env
nano .env
```

```env
# Tu IP
MY_IP=192.168.1.20

# Tu dominio falso
MY_DOMAIN=pc2.lab.local

# IP de tu compañero (quien tiene PC1)
PEER_IP=192.168.1.10

# Dominio falso de tu compañero
PEER_DOMAIN=pc1.lab.local

# Tu usuario de Roundcube
MAIL_USER=alumno2

# Tu contraseña
MAIL_PASSWORD=mipass456
```

> **Importante:** Los dominios que elijan (`MY_DOMAIN` y `PEER_DOMAIN`) son
> completamente inventados. No necesitan existir en internet. Lo unico que
> importa es que la PC1 y PC2 usen los mismos valores pero intercambiados.
> Ejemplo: si PC1 tiene `MY_DOMAIN=pedro.correo.local`, entonces PC2 debe
> tener `PEER_DOMAIN=pedro.correo.local`.

---

## Parte 5 — Abrir Puertos en el Firewall

Rocky Linux 9 trae el firewall activado por defecto (`firewalld`).
Necesitamos abrir los puertos que usaran los contenedores.

Ejecuten esto **en ambas PCs**:

```bash
# Puerto 25  → SMTP (envio de correo)
sudo firewall-cmd --permanent --add-port=25/tcp

# Puerto 143 → IMAP (recepcion/lectura de correo)
sudo firewall-cmd --permanent --add-port=143/tcp

# Puerto 80  → HTTP (interfaz web Roundcube)
sudo firewall-cmd --permanent --add-port=80/tcp

# Aplicar los cambios
sudo firewall-cmd --reload
```

Verifica que los puertos quedaron abiertos:

```bash
sudo firewall-cmd --list-ports
```

Deberia mostrar: `25/tcp 143/tcp 80/tcp`

---

## Parte 6 — Configurar SELinux

SELinux puede bloquear que los contenedores de Docker usen ciertos puertos
del sistema. Ejecuten estos comandos **en ambas PCs**:

### 6.1 Instalar las herramientas de SELinux

```bash
sudo dnf install -y policycoreutils-python-utils
```

### 6.2 Permitir el puerto 25 para SMTP

```bash
# Verificar si el puerto 25 ya esta asignado
sudo semanage port -l | grep smtp

# Si no aparece, agregarlo:
sudo semanage port -a -t smtp_port_t -p tcp 25
# Si ya existe y marca error "already defined", usar -m en vez de -a:
sudo semanage port -m -t smtp_port_t -p tcp 25
```

### 6.3 Permitir el puerto 143 para IMAP

```bash
sudo semanage port -l | grep imap

sudo semanage port -a -t imap_port_t -p tcp 143
# Si ya existe:
sudo semanage port -m -t imap_port_t -p tcp 143
```

### 6.4 Habilitar que los contenedores gestionen la red

```bash
sudo setsebool -P container_manage_cgroup on
sudo setsebool -P container_use_devices on
```

### 6.5 (Opcional) Si siguen teniendo problemas con SELinux

En caso de que algo siga fallando por SELinux y necesiten depurar rapidamente,
pueden poner SELinux en modo permisivo **temporalmente** (solo mientras prueban):

```bash
# Solo para pruebas, se revierte al reiniciar
sudo setenforce 0

# Para verificar el modo actual
getenforce
```

Para dejarlo permanentemente en modo permisivo durante la practica:

```bash
sudo sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
sudo reboot
```

---

## Parte 7 — Levantar los Servicios con Docker

### PC1 — Levantar Postfix + Dovecot + Roundcube

```bash
cd ~/smtp-imap/PC1

# Construir imagenes y levantar contenedores en segundo plano
docker compose up -d --build
```

El primer `--build` tomara unos minutos porque descarga las imagenes base
y construye los contenedores. Las siguientes veces sera mucho mas rapido.

Verifica que los tres contenedores esten corriendo:

```bash
docker compose ps
```

Deberias ver algo como:

```
NAME              IMAGE             STATUS          PORTS
pc1_postfix       pc1-postfix       Up              0.0.0.0:25->25/tcp
pc1_dovecot       pc1-dovecot       Up              0.0.0.0:143->143/tcp
pc1_roundcube     roundcube/...     Up              0.0.0.0:80->80/tcp
```

### PC2 — Levantar Exim + Dovecot + Roundcube

```bash
cd ~/smtp-imap/PC2

docker compose up -d --build

docker compose ps
```

```
NAME              IMAGE             STATUS          PORTS
pc2_exim          pc2-exim          Up              0.0.0.0:25->25/tcp
pc2_dovecot       pc2-dovecot       Up              0.0.0.0:143->143/tcp
pc2_roundcube     roundcube/...     Up              0.0.0.0:80->80/tcp
```

---

## Parte 8 — Acceder a Roundcube y Enviar un Correo

### 8.1 Abrir Roundcube en el navegador

Desde cualquier navegador, entra a:

```
http://<TU_IP>
```

Por ejemplo: `http://192.168.1.10`

### 8.2 Iniciar sesion

Usa las credenciales que configuraste en tu `.env`:

| Campo    | Valor de ejemplo                |
|----------|---------------------------------|
| Usuario  | `alumno1@pc1.lab.local`         |
| Contraseña | `mipass123`                   |

> El usuario debe incluir el `@` y tu dominio. Si pusiste `MAIL_USER=pedro`
> y `MY_DOMAIN=pedro.correo.local`, entonces el login es `pedro@pedro.correo.local`.

### 8.3 Enviar un correo al compañero

1. Haz clic en **Redactar** (icono de lapiz o boton "Compose")
2. En el campo **Para:** escribe la direccion de tu compañero:
   - Si tu compañero tiene `MAIL_USER=alumno2` y `MY_DOMAIN=pc2.lab.local`
   - Escribe: `alumno2@pc2.lab.local`
3. Escribe un asunto y un mensaje
4. Haz clic en **Enviar**

### 8.4 Verificar que llego el correo

Tu compañero debe abrir `http://<SU_IP>` en su navegador,
iniciar sesion con sus credenciales y revisar su **Bandeja de Entrada**.

---

## Parte 9 — Solucion de Problemas (Troubleshooting)

### Ver los logs de un servicio

Si algo no funciona, lo primero es revisar los logs:

```bash
# Logs de todos los servicios (PC1)
docker compose logs

# Logs solo de postfix
docker compose logs postfix

# Logs en tiempo real (Ctrl+C para salir)
docker compose logs -f

# Logs de dovecot con timestamps
docker compose logs -t dovecot
```

### Entrar dentro de un contenedor para depurar

```bash
# Entrar al contenedor de postfix
docker compose exec postfix sh

# Entrar al contenedor de exim (PC2)
docker compose exec exim sh

# Entrar al contenedor de dovecot
docker compose exec dovecot sh
```

### Verificar que los puertos estan escuchando

```bash
# Ver todos los puertos en uso
ss -tlnp

# Ver solo si el puerto 25 esta activo
ss -tlnp | grep :25

# Ver si el puerto 143 esta activo
ss -tlnp | grep :143
```

### Probar SMTP manualmente desde la terminal

Puedes simular el envio de un correo usando `telnet` o `nc`:

```bash
# Instalar telnet si no lo tienes
sudo dnf install -y telnet

# Conectar al servidor SMTP de tu compañero
telnet <IP_compañero> 25
```

Si la conexion funciona, veras algo como:
```
220 pc2.lab.local ESMTP
```

Escribe `QUIT` y `Enter` para salir.

### Verificar que el firewall no este bloqueando

```bash
# Ver reglas activas
sudo firewall-cmd --list-all

# Ver puertos abiertos
sudo firewall-cmd --list-ports
```

### Verificar que SELinux no este bloqueando

```bash
# Ver los ultimos bloqueos de SELinux
sudo ausearch -m avc -ts recent

# Ver en tiempo real
sudo journalctl -f | grep avc
```

### Reiniciar todos los servicios

```bash
docker compose restart

# O bajar y volver a levantar
docker compose down
docker compose up -d
```

### Reiniciar solo un servicio

```bash
docker compose restart postfix
docker compose restart dovecot
docker compose restart roundcube
```

### Limpiar todo y empezar de cero

```bash
# Detener y eliminar contenedores y volumenes
docker compose down -v

# Volver a construir desde cero
docker compose up -d --build
```

> **Advertencia:** `down -v` borra los correos guardados en los volumenes.
> Usalo solo si quieres un inicio limpio.

---

## Referencia Rapida de Comandos

| Tarea | Comando |
|-------|---------|
| Ver mi IP | `ip addr show \| grep "inet "` |
| Levantar servicios | `docker compose up -d --build` |
| Ver estado | `docker compose ps` |
| Ver logs | `docker compose logs -f` |
| Parar servicios | `docker compose down` |
| Abrir puerto en firewall | `sudo firewall-cmd --permanent --add-port=XX/tcp` |
| Aplicar cambios firewall | `sudo firewall-cmd --reload` |
| Ver puertos abiertos | `sudo firewall-cmd --list-ports` |
| Test conexion SMTP | `telnet <IP> 25` |
| Entrar a un contenedor | `docker compose exec <servicio> sh` |

---

## Informacion Tecnica (Para el Curioso)

### ¿Como saben los contenedores donde esta el compañero sin DNS?

Los archivos `docker-compose.yml` incluyen una seccion `extra_hosts` que agrega
entradas directamente al archivo `/etc/hosts` de cada contenedor:

```yaml
extra_hosts:
  - "pc1.lab.local:192.168.1.10"
  - "pc2.lab.local:192.168.1.20"
```

Esto hace que cuando Postfix o Exim quieren enviar un correo a `pc2.lab.local`,
el sistema operativo ya sabe que esa es la IP `192.168.1.20`, sin necesitar
un servidor DNS.

### Flujo de un correo de PC1 a PC2

```
1. El alumno escribe un correo en Roundcube (PC1)
2. Roundcube se conecta a Postfix en el puerto 25 (dentro del contenedor)
3. Postfix ve que el destinatario es @pc2.lab.local
4. Postfix consulta su tabla de transporte y sabe que debe ir a 192.168.1.20:25
5. Postfix se conecta a Exim en PC2 por la red real
6. Exim en PC2 recibe el correo y lo entrega a Dovecot via LMTP (puerto 24)
7. Dovecot guarda el correo en el maildir del destinatario
8. El alumno de PC2 abre Roundcube → Roundcube consulta Dovecot via IMAP (puerto 143)
9. El correo aparece en la bandeja de entrada
```

### ¿Por que SQLite en Roundcube?

Roundcube necesita una base de datos para guardar preferencias, libretas de
contactos, etc. SQLite es una base de datos en un solo archivo, no necesita
un servidor separado. Para una practica de laboratorio es mas que suficiente.

---

*Practica elaborada para el curso de Redes — Rocky Linux 9 + Docker*
