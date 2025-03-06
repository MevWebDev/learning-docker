#!/bin/bash





info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

NODE_VERSION="12"

info "CONFIGURING" "We are using node version: $NODE_VERSION"

info "CONTAINER" "Creating and running node.js container"

CONTAINER_ID=$(docker run -d -p 8080:8080 --name docker-node-demo -it node:$NODE_VERSION-alpine tail -f /dev/null)

info "CREATED" "Created container of ID: $CONTAINER_ID"

docker exec $CONTAINER_ID mkdir -p /app

info "COPYING"

docker cp package.json $CONTAINER_ID:/app/
docker cp app.js $CONTAINER_ID:/app/

info "DEPENDENCIES"

docker exec -w /app $CONTAINER_ID npm install

info "RUNNING"

docker exec -w /app $CONTAINER_ID node app.js