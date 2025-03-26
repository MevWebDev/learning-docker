#!/bin/bash

info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

if [ $(docker ps -a -q -f name=node-container) ]; then
    info "REMOVING" "Removing existing node-container container"
    docker rm -f node-container
fi

info "CREATING" "Creating nodejs_data volume"

volume=$(docker volume create nodejs_data)

info "STARTING" "Starting Node.js container"

container=$(docker run -d --name node-container --volume $volume:/app node:alpine tail -f /dev/null )

info "ADDING" "Copying local file to nodejs_data volume"
echo "console.log('Hello from Node.js!');" > app.js

docker run --rm \
 -v $volume:/app \
 -v $(pwd):/local \
 alpine sh -c "cp /local/app.js /app"

info "DONE" "Added local file to nodejs_data volume"

info "CREATING" "Creating all_volumes volume"
all_volumes=$(docker volume create all_volumes)

info "COPYING" "Copying from nginx-volume and nodejs_data to all_volumes"

docker run --rm \
 -v nginx-volume:/nginx \
 -v $volume:/nodejs \
 -v $all_volumes:/data \
 alpine sh -c "cp -r /nginx/* /data/ 2>/dev/null && cp -r /nodejs/* /data/ 2>/dev/null || echo 'No files to copy'"

info "DONE" "Data copied from nginx-volume to all_volumes"

