#!/bin/bash

set -e

# Kolory dla poprawy czytelności
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funkcja pomocnicza do sprawdzania czy wolumin istnieje
volume_exists() {
    docker volume inspect "$1" >/dev/null 2>&1
}

# Funkcja szyfrująca wolumin
encrypt_volume() {
    local volume_name=$1
    local password=$2
    
    echo -e "${YELLOW}Przygotowywanie do szyfrowania woluminu ${volume_name}...${NC}"
    
    if ! volume_exists "$volume_name"; then
        echo -e "${RED}Wolumin ${volume_name} nie istnieje!${NC}"
        exit 1
    fi
    
    # Tworzenie tymczasowego kontenera do operacji
    docker run --rm -v "${volume_name}":/volume_data alpine sh -c \
        "apk add --no-cache tar gnupg && \
        cd /volume_data && \
        tar czf - . | gpg --batch --symmetric --passphrase \"${password}\" --cipher-algo AES256 -o /tmp/encrypted_volume.tar.gz.gpg && \
        rm -rf /volume_data/* && \
        mv /tmp/encrypted_volume.tar.gz.gpg /volume_data/"
    
    echo -e "${GREEN}Wolumin ${volume_name} został pomyślnie zaszyfrowany!${NC}"
}

# Funkcja tworząca nowy zaszyfrowany wolumin
create_encrypted_volume() {
    local volume_name=$1
    local password=$2
    
    echo -e "${YELLOW}Tworzenie nowego zaszyfrowanego woluminu ${volume_name}...${NC}"
    
    if volume_exists "$volume_name"; then
        echo -e "${RED}Wolumin ${volume_name} już istnieje!${NC}"
        exit 1
    fi
    
    docker volume create "${volume_name}"
    
    # Tworzenie pliku README z instrukcją
    docker run --rm -v "${volume_name}":/volume_data alpine sh -c \
        "echo 'Ten wolumin jest zaszyfrowany. Aby odszyfrować, użyj skryptu z opcją --decrypt.' > /volume_data/README.txt && \
        echo 'Użyj hasła, które zostało ustawione podczas tworzenia woluminu.' >> /volume_data/README.txt"
    
    # Szyfrowanie nowego woluminu
    encrypt_volume "$volume_name" "$password"
    
    echo -e "${GREEN}Nowy zaszyfrowany wolumin ${volume_name} został utworzony!${NC}"
}

# Funkcja odszyfrowująca wolumin
decrypt_volume() {
    local volume_name=$1
    local password=$2
    
    echo -e "${YELLOW}Przygotowywanie do odszyfrowania woluminu ${volume_name}...${NC}"
    
    if ! volume_exists "$volume_name"; then
        echo -e "${RED}Wolumin ${volume_name} nie istnieje!${NC}"
        exit 1
    fi
    
    # Tworzenie tymczasowego kontenera do operacji
    docker run --rm -v "${volume_name}":/volume_data alpine sh -c \
        "apk add tar gpg && \
        cd /volume_data && \
        if [ ! -f encrypted_volume.tar.gz.gpg ]; then \
            echo 'Brak zaszyfrowanego pliku w woluminie!'; \
            exit 1; \
        fi && \
        gpg --batch --passphrase \"${password}\" --decrypt encrypted_volume.tar.gz.gpg | tar xzf - && \
        rm -f encrypted_volume.tar.gz.gpg"
    
    echo -e "${GREEN}Wolumin ${volume_name} został pomyślnie odszyfrowany!${NC}"
}

# Wyświetlanie pomocy
show_help() {
    echo "Użycie: $0 [OPCJE]"
    echo
    echo "Opcje:"
    echo "  --encrypt <nazwa_woluminu> <hasło>   Zaszyfruj istniejący wolumin"
    echo "  --create <nazwa_woluminu> <hasło>    Utwórz nowy zaszyfrowany wolumin"
    echo "  --decrypt <nazwa_woluminu> <hasło>   Odszyfruj wolumin"
    echo "  --help                               Wyświetl tę pomoc"
    echo
    echo "Przykłady:"
    echo "  $0 --encrypt my_volume moje_haslo"
    echo "  $0 --create secure_data tajne_haslo"
    echo "  $0 --decrypt secure_data tajne_haslo"
    exit 0
}

# Główna logika skryptu
if [ $# -eq 0 ]; then
    show_help
fi

case "$1" in
    --encrypt)
        if [ $# -ne 3 ]; then
            echo -e "${RED}Nieprawidłowa liczba argumentów!${NC}"
            show_help
        fi
        encrypt_volume "$2" "$3"
        ;;
    --create)
        if [ $# -ne 3 ]; then
            echo -e "${RED}Nieprawidłowa liczba argumentów!${NC}"
            show_help
        fi
        create_encrypted_volume "$2" "$3"
        ;;
    --decrypt)
        if [ $# -ne 3 ]; then
            echo -e "${RED}Nieprawidłowa liczba argumentów!${NC}"
            show_help
        fi
        decrypt_volume "$2" "$3"
        ;;
    --help)
        show_help
        ;;
    *)
        echo -e "${RED}Nieznana opcja!${NC}"
        show_help
        ;;
esac

exit 0