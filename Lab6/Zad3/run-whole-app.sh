#!/bin/bash

info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

docker rm -f frontend backend postgres || true


info "RUNNING FRONTEND" "Running Frontend container on port:3000"

docker run -d --name frontend --network frontend_network -p 3000:3000 frontend-app

info "RUNNING BACKEND" "Running Backend container on port:3001"

docker run -d --name backend \
  --network backend_network \
  -p 3001:3001 \
  express-backend

docker network connect frontend_network backend


info "RUNNING DATABASE" "Running Database container on port:5432"

docker run -d --name postgres \
  --network backend_network \
  -e POSTGRES_USER=myuser \
  -e POSTGRES_PASSWORD=mypassword \
  -e POSTGRES_DB=myapp \
  -v postgres_data:/var/lib/postgresql/data \
  postgres:14

  # Verify connections
info "VERIFICATION" "Checking if containers are running"
docker ps | grep -E 'frontend|backend|postgres'