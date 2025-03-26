#!/bin/bash

info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}


if [ $(docker ps -a -q -f name=my-nginx) ]; then
    info "REMOVING" "Removing existing my-nginx container"
    docker rm -f my-nginx
fi

info "CREATE" "Creating nginx volume"
volume=$(docker volume create nginx-volume)


info "MODIFYING" "Adding custom HTML to volume"
docker run --rm -v $volume:/data alpine sh -c "echo '<html><body><h1>Custom Nginx Content from Docker Volume</h1><p>This content is served from a Docker volume.</p></body></html>' > /data/index.html"

info "STARTING" "Starting nginx container"
docker run -d --name my-nginx -p 8080:80 --volume $volume:/usr/share/nginx/html nginx

info "DONE" "Nginx container is running with custom HTML"
info "ACCESS" "Open http://localhost:8080 in your browser"