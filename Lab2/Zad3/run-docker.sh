#!/bin/bash

# Funkcja do wyświetlania informacji
info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

# Usuń istniejące kontenery, jeśli istnieją
info "CLEANUP" "Usuwanie istniejących kontenerów..."
docker rm -f node-app mongo || true

# Uruchom kontener z MongoDB
info "MONGO" "Uruchamianie kontenera MongoDB..."
docker run -d --name mongo -p 27017:27017 mongo:latest

# Zbuduj obraz aplikacji Node.js
info "BUILD" "Budowanie obrazu aplikacji Node.js..."
docker build -t node-mongo-app .

# Uruchom kontener z aplikacją Node.js
info "RUN" "Uruchamianie kontenera aplikacji Node.js..."
docker run -d --name node-app -p 8080:8080 --link mongo:mongo node-mongo-app

# Poczekaj, aż aplikacja się uruchomi
info "WAIT" "Oczekiwanie na uruchomienie aplikacji..."
sleep 10

# Dodaj przykładowe dane do bazy
info "SEED" "Dodawanie przykładowych danych do bazy..."
curl -s http://localhost:8080/seed

# Pobierz dane z bazy
info "TEST" "Pobieranie danych z bazy..."
curl -s http://localhost:8080/items | jq

info "SUCCESS" "Aplikacja działa! Otwórz http://localhost:8080/items w przeglądarce."