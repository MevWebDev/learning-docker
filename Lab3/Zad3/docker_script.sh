#!/bin/bash

info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

# Utworzenie sieci Docker do komunikacji między kontenerami
info "TWORZENIE" "Sieci Docker dla kontenerów"
docker network create node-nginx-network

# Uruchomienie kontenera Node.js
info "URUCHAMIANIE" "Kontenera Node.js"
NODE_CONTAINER_ID=$(docker run -d --name docker-node --network node-nginx-network -p 3000:3000 -it node:22-alpine tail -f /dev/null)
info "UTWORZONO" "Kontener Node.js"

# Utworzenie konfiguracji Nginx
info "KONFIGURACJA" "Tworzenie plików konfiguracyjnych dla Nginx"
mkdir -p nginx/conf.d
mkdir -p nginx/ssl
mkdir -p nginx/cache

# Generowanie certyfikatu SSL
info "SSL" "Generowanie certyfikatu self-signed"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout nginx/ssl/nginx.key -out nginx/ssl/nginx.crt \
    -subj "/C=PL/ST=State/L=City/O=Organization/CN=localhost"

# Tworzenie pliku konfiguracyjnego Nginx
cat > nginx/conf.d/default.conf << 'EOF'
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=100m inactive=60m;

server {
    listen 80;
    server_name localhost;

    # Przekierowanie HTTP na HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name localhost;

    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256';
    
    # Cache configuration
    proxy_cache my_cache;
    proxy_cache_valid 200 302 10m;
    proxy_cache_valid 404 1m;
    add_header X-Cache-Status $upstream_cache_status;

    location / {
        proxy_pass http://docker-node:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Uruchomienie kontenera Nginx
info "URUCHAMIANIE" "Kontenera Nginx"
NGINX_CONTAINER_ID=$(docker run -d --name docker-nginx \
    --network node-nginx-network \
    -p 80:80 -p 443:443 \
    -v $(pwd)/nginx/conf.d:/etc/nginx/conf.d \
    -v $(pwd)/nginx/ssl:/etc/nginx/ssl \
    -v $(pwd)/nginx/cache:/var/cache/nginx \
    nginx:alpine)
info "UTWORZONO" "Kontener Nginx"

# Instalacja expressa w kontenerze Node.js i utworzenie aplikacji
info "KONFIGURACJA" "Instalacja Express.js i utworzenie aplikacji"
docker exec docker-node sh -c "mkdir -p /app && cd /app && npm init -y && npm install express"

# Tworzenie prostej aplikacji Express
cat > app.js << 'EOF'
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello from Node.js behind Nginx reverse proxy with SSL and cache!');
});

app.listen(port, () => {
  console.log(`Aplikacja Node.js działa na porcie ${port}`);
});
EOF

# Kopiowanie aplikacji do kontenera Node.js i uruchomienie
docker cp app.js docker-node:/app/
info "URUCHAMIANIE" "Aplikacji Node.js"
docker exec -d docker-node sh -c "cd /app && node app.js"

info "ZAKOŃCZONO" "Aplikacja Node.js działa na porcie 3000"
info "ZAKOŃCZONO" "Nginx działa jako reverse proxy na portach 80 (HTTP->HTTPS) i 443 (HTTPS)"
info "INFO" "Aby sprawdzić działanie, przejdź do https://localhost"