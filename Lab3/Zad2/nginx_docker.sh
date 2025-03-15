#!/bin/bash

# Funkcja do tworzenia kontenera Nginx
create_nginx_container() {
    local port=$1

    # Tworzenie tymczasowego katalogu z zawartością strony
    local temp_dir=$(mktemp -d)

    # Uruchamianie kontenera Nginx
    docker run --name my-nginx -p "$port:80" -v "$temp_dir:/usr/share/nginx/html" -d nginx

    # Sprawdzenie, czy kontener został uruchomiony
    if docker ps | grep -q "my-nginx"; then
        echo "Kontener Nginx został uruchomiony na porcie $port."
    else
        echo "Błąd: Kontener Nginx nie został uruchomiony."
        exit 1
    fi
}

# Funkcja do zmiany konfiguracji Nginx
update_nginx_config() {
    local config_file=$1

    # Znajdowanie ID kontenera
    local container_id=$(docker ps -q --filter "name=my-nginx")

    if [ -z "$container_id" ]; then
        echo "Błąd: Kontener Nginx nie jest uruchomiony."
        exit 1
    fi

    # Kopiowanie nowej konfiguracji do kontenera
    docker cp "$config_file" "$container_id:/etc/nginx/nginx.conf"

    # Zrestartowanie kontenera, aby zastosować zmiany
    docker restart "$container_id"

    echo "Konfiguracja Nginx została zaktualizowana."
}

# Główna logika skryptu
if [ "$#" -lt 1 ]; then
    echo "Użycie: $0 <port> [--update-config <plik_konfiguracyjny>]"
    echo "  --update-config: Zaktualizuj konfigurację Nginx w działającym kontenerze."
    exit 1
fi

port=$1
config_file=${3:-""}
update_config=${2:-""}

# Sprawdzenie, czy kontener jest już uruchomiony
container_id=$(docker ps -q --filter "name=my-nginx")

if [ "$update_config" == "--update-config" ]; then
    if [ -z "$container_id" ]; then
        echo "Błąd: Kontener Nginx nie jest uruchomiony. Najpierw uruchom kontener bez opcji --update-config."
        exit 1
    else
        # Tylko aktualizacja konfiguracji
        if [ -z "$config_file" ]; then
            echo "Błąd: Nie podano pliku konfiguracyjnego."
            exit 1
        fi
        update_nginx_config "$config_file"
    fi
else
    if [ -n "$container_id" ]; then
        echo "Błąd: Kontener Nginx jest już uruchomiony. Użyj opcji --update-config, aby zaktualizować konfigurację."
        exit 1
    else
        # Tworzenie kontenera
        create_nginx_container "$port"
    fi
fi