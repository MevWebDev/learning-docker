#!/bin/bash

echo "Sprawdzanie zużycia woluminów Docker w procentach..."
echo "---------------------------------------------------"

# Pobranie informacji o woluminach
volumes=$(docker volume ls -q)

if [ -z "$volumes" ]; then
    echo "Brak woluminów Docker do sprawdzenia."
    exit 0
fi

# Pobranie całkowitej pamięci przydzielonej Dockerowi (w bajtach)
docker_mem_bytes=$(docker info --format '{{json .MemTotal}}' 2>/dev/null | numfmt --from=iec 2>/dev/null)

if [ -z "$docker_mem_bytes" ] || [ "$docker_mem_bytes" -eq 0 ]; then
    echo "Nie można określić całkowitej pamięci Dockera."
    echo "Pokazuję tylko rozmiary woluminów bez procentów."
    docker_mem_bytes=0
    show_percentages=false
else
    show_percentages=true
    human_docker_mem=$(numfmt --to=iec-i --suffix=B $docker_mem_bytes)
    echo "Całkowita pamięć przydzielona Dockerowi: $human_docker_mem"
fi

# Obliczanie całkowitego rozmiaru woluminów w bajtach
total_bytes=0
declare -A volume_bytes

for volume in $volumes; do
    # Pobranie rozmiaru woluminu w bajtach
    size_in_bytes=$(docker run --rm -v $volume:/vol alpine sh -c "du -sb /vol 2>/dev/null | cut -f1" || echo "0")
    volume_bytes[$volume]=$size_in_bytes
    total_bytes=$((total_bytes + size_in_bytes))
done

echo -e "\n| NAZWA WOLUMINU | ROZMIAR | WYKORZYSTANIE % |"
echo "|----------------|---------|----------------|"

for volume in $volumes; do
    # Sprawdzenie rozmiaru zawartości woluminu (human-readable)
    volume_size=$(docker run --rm -v $volume:/vol alpine sh -c "du -sh /vol 2>/dev/null | cut -f1" || echo "0B")
    
    # Obliczenie procentowego wykorzystania
    if [ "$show_percentages" = true ]; then
        if [ $docker_mem_bytes -eq 0 ]; then
            percentage="N/A"
        else
            percentage=$(awk "BEGIN {printf \"%.2f%%\", (${volume_bytes[$volume]} / $docker_mem_bytes) * 100}")
        fi
    else
        percentage="N/A"
    fi
    
    printf "| %-14s | %-7s | %-14s |\n" "$volume" "$volume_size" "$percentage"
done

# Podsumowanie
echo -e "\nPodsumowanie:"
human_total=$(numfmt --to=iec-i --suffix=B $total_bytes 2>/dev/null || echo "$total_bytes bajtów")
echo "Całkowity rozmiar woluminów: $human_total"

if [ "$show_percentages" = true ]; then
    total_percentage=$(awk "BEGIN {printf \"%.2f%%\", ($total_bytes / $docker_mem_bytes) * 100}")
    echo "Procent wykorzystania pamięci Dockera: $total_percentage"
fi

