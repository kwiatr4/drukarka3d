#!/usr/bin/env bash
# Skrypt pobierający oficjalny obraz CB1 (zgodny z BTT Pi) na lokalny komputer.
# Uwaga: nie umieszczamy dużych obrazów binarnych w repozytorium.
# Użyj tego skryptu na swoim laptopie, by pobrać obraz bezpośrednio z serwera.

set -euo pipefail

USAGE="Usage: $0 [-u URL] [-o OUT]
  -u URL   direct URL to image (.img or .zip)
  -o OUT   output filename (default: downloaded_image.img)

If no -u provided the script will print instructions how to get the correct
image from the BIGTREETECH CB1 releases page.
"

OUT="downloaded_image.img"
URL=""

# Verified latest known Klipper image for CB1/BTT Pi at the time of writing.
DEFAULT_CB1_URL="https://github.com/bigtreetech/CB1/releases/download/V3.1.0/CB1_Debian13_Klipper_kernel7.0_20260430.img.xz"

while getopts ":u:o:h" opt; do
  case $opt in
    u) URL="$OPTARG" ;;
    o) OUT="$OPTARG" ;;
    h) echo "$USAGE"; exit 0 ;;
    \?) echo "Invalid option -$OPTARG" >&2; echo "$USAGE"; exit 1 ;;
  esac
done

if [ -z "$URL" ]; then
  cat <<'EOF'
Brak URL.

Oficjalnie BTT Pi używa obrazów jak CB1 (repo BTT-Pi odsyła do CB1).
Najbezpieczniejszy wybór to obraz "Klipper" z repo CB1.

Release page:
  https://github.com/bigtreetech/CB1/releases

Przykład pobrania obrazu Klipper:
  ./download_mainsailos.sh -u https://github.com/bigtreetech/CB1/releases/download/V3.1.0/CB1_Debian13_Klipper_kernel7.0_20260430.img.xz -o cb1-klipper.img.xz

Jeśli chcesz, uruchom bez -u i potwierdź użycie domyślnego URL w skrypcie (edytując zmienną DEFAULT_CB1_URL).
EOF
  exit 0
fi

echo "Pobieram: $URL"

if command -v curl >/dev/null 2>&1; then
  curl -L --progress-bar -o "$OUT" "$URL"
elif command -v wget >/dev/null 2>&1; then
  wget -O "$OUT" "$URL"
else
  echo "Zainstaluj curl lub wget." >&2
  exit 1
fi

echo "Pobrano do: $OUT"
echo "Jeśli to .xz/.zip, balenaEtcher potrafi to bezpośrednio flashować na kartę SD." 
echo
echo "Po włożeniu karty do BTT Pi i uruchomieniu pamiętaj, aby na BTT Pi zainstalować wymagane pakiety do sterowania host GPIO:" 
echo "  sudo apt update && sudo apt install -y python3-rpi.gpio python3-serial"
echo "Sprawdź też istnienie socketu host MCU, np. /tmp/klipper_host_mcu (patrz INSTALL-Klipper-BTT-Pi.md)."
