#!/bin/bash

# Funkcja do tworzenia kontenera Nginx
create_nginx_container() {
    local port=$1
    local html_content=$2

    # Tworzenie tymczasowego katalogu z zawartością strony
    local temp_dir=$(mktemp -d)
    echo "$html_content" > "$temp_dir/index.html"

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

# Funkcja do zmiany zawartości strony
update_nginx_content() {
    local port=$1
    local html_content=$2

    # Znajdowanie ID kontenera
    local container_id=$(docker ps -q --filter "name=my-nginx")

    if [ -z "$container_id" ]; then
        echo "Błąd: Kontener Nginx nie jest uruchomiony."
        exit 1
    fi

    # Tworzenie tymczasowego katalogu z nową zawartością
    local temp_dir=$(mktemp -d)
    echo "$html_content" > "$temp_dir/index.html"

    # Kopiowanie nowej zawartości do kontenera
    docker cp "$temp_dir/index.html" "$container_id:/usr/share/nginx/html/index.html"

    echo "Zawartość strony została zaktualizowana."
}

# Funkcja do testowania strony
test_nginx_content() {
    local port=$1
    local expected_content=$2

    # Pobieranie zawartości strony
    local response=$(curl -s "http://localhost:$port")

    if [ "$response" == "$expected_content" ]; then
        echo "Test passed: Zawartość strony jest poprawna."
    else
        echo "Test failed: Zawartość strony jest niepoprawna."
        echo "Oczekiwano: $expected_content"
        echo "Otrzymano: $response"
        exit 1
    fi
}

# Główna logika skryptu
if [ "$#" -lt 2 ]; then
    echo "Użycie: $0 <port> <html_content> [--update]"
    echo "  --update: Tylko zaktualizuj zawartość strony (kontener musi być już uruchomiony)."
    exit 1
fi

port=$1
html_content=$2
update_only=${3:-false}

# Sprawdzenie, czy kontener jest już uruchomiony
container_id=$(docker ps -q --filter "name=my-nginx")

if [ "$update_only" == "--update" ]; then
    if [ -z "$container_id" ]; then
        echo "Błąd: Kontener Nginx nie jest uruchomiony. Najpierw uruchom kontener bez opcji --update."
        exit 1
    else
        # Tylko aktualizacja zawartości
        update_nginx_content "$port" "$html_content"
        test_nginx_content "$port" "$html_content"
    fi
else
    if [ -n "$container_id" ]; then
        echo "Błąd: Kontener Nginx jest już uruchomiony. Użyj opcji --update, aby zaktualizować zawartość."
        exit 1
    else
        # Tworzenie kontenera i ustawienie początkowej zawartości
        create_nginx_container "$port" "$html_content"
        test_nginx_content "$port" "$html_content"
    fi
fi