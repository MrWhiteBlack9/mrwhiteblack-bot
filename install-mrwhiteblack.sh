#!/bin/bash

# -------------------------------
# SCRIPT DE DÉPLOIEMENT MrWhiteBlack
# VPS Ubuntu 22.04 + Docker + SSL + Bot Telegram
# Domaine : mrwhiteblack.site
# -------------------------------

# --- CONFIGURATION ---
USERNAME=mrwhiteblack
SSH_PORT=4422
DOMAIN=mrwhiteblack.site
EMAIL=abdrahmanalikhlas@gmail.com
BOT_REPO=https://github.com/MrWhiteBlack9/mrwhiteblack-bot.git

echo "[1/8] Mise à jour du système..."
apt update && apt upgrade -y

# --- CRÉATION UTILISATEUR NON ROOT ---
echo "[2/8] Création utilisateur $USERNAME"
adduser $USERNAME
usermod -aG sudo $USERNAME

# --- INSTALLATION DES DÉPENDANCES ---
echo "[3/8] Installation des dépendances"
apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

# --- INSTALLATION DE DOCKER ---
echo "[4/8] Installation de Docker"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt update
apt install -y docker-ce docker-compose

# --- INSTALLATION NGINX & SSL ---
echo "[5/8] Installation de Nginx et SSL Certbot"
apt install -y nginx certbot python3-certbot-nginx

# --- CONFIGURATION NGINX ---
echo "[6/8] Configuration Nginx pour reverse proxy"
cat > /etc/nginx/sites-available/$DOMAIN <<EOL
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOL

ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# --- CERTIFICAT SSL ---
echo "[7/8] Obtention du certificat SSL pour $DOMAIN"
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL

# --- CLONAGE DU BOT ---
echo "[8/8] Clonage du bot Telegram"
cd /home/$USERNAME
git clone $BOT_REPO bot
cd bot
chown -R $USERNAME:$USERNAME /home/$USERNAME

echo "--- DÉPLOIEMENT TERMINÉ ---"
echo "Connecte-toi en tant que $USERNAME avec : ssh $USERNAME@$(hostname -I | awk '{print $1}') -p $SSH_PORT"
echo "Ton bot est déployé sur https://$DOMAIN"
echo "N'oublie pas de configurer .env avec ton BOT_TOKEN"
