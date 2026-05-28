# Jak pobrać obraz dla BTT Pi (szybko)

Nie dodajemy dużych obrazów binarnych do repo. Zamiast tego użyj prostego skryptu
`download_mainsailos.sh`, który pobierze wskazany plik obrazu na Twój laptop.

Ważne: repo `BTT-Pi` wskazuje, że obraz systemu dla BTT Pi należy brać tak jak dla `CB1`.
Dlatego zalecany jest oficjalny obraz z:
`https://github.com/bigtreetech/CB1/releases`

Kroki:

1. Na laptopie z kartą SD lub z dostępem do internetu sklonuj repo (jeśli jeszcze nie):
```bash
git clone <twoje-repo>
cd drukarka3d/BTT-Pi
```

2. Jeśli masz bezpośredni link do obrazu (z CB1 Releases), uruchom:
```bash
./download_mainsailos.sh -u "https://github.com/bigtreetech/CB1/releases/download/V3.1.0/CB1_Debian13_Klipper_kernel7.0_20260430.img.xz" -o cb1-klipper.img.xz
```

3. Rozpakuj (jeśli to .zip/.xz) i nagraj obraz na kartę microSD używając balenaEtcher, Raspberry Pi Imager
   lub `dd` (uważaj na właściwy device).

4. Włóż kartę do BTT Pi i uruchom. W web UI (Mainsail/Fluidd) wgraj plik
   `printer-artillery-sidewinder-x2-bttpi.cfg` jako `printer.cfg` (Machine → Upload).

Jeśli chcesz, mogę też przygotować archiwum ZIP z `printer.cfg` i instrukcją gotowe do pobrania.

Uwaga po starcie BTT Pi:

- Aby Klipper mógł sterować GPIO hosta (np. `host:gpio211`) zainstaluj na BTT Pi pakiety:

```bash
sudo apt update
sudo apt install -y python3-rpi.gpio python3-serial
```

- Sprawdź też, czy Klipper utworzył socket host MCU (w przykładach `/tmp/klipper_host_mcu`):

```bash
ls -l /tmp/klipper_host_mcu
```

Jeśli socket nie istnieje, sprawdź logi Klippera i instrukcję RPi microcontroller: https://www.klipper3d.org/RPi_microcontroller.html
