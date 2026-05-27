# Szybka instrukcja: Klipper na BTT Pi V1.2 + Sidewinder X2 (Artillery_Ruby-v1.2)

Stan końcowy, który działa w tym repo:
- `printer.cfg` ma na górze `[include mainsail.cfg]`
- `mainsail.cfg` jest zgodny z Klipperem i nie używa sekcji `[mainsail]`
- plik `printer-artillery-sidewinder-x2-bttpi.cfg` zawiera `host:gpio211` oraz `[mcu host] serial: /tmp/klipper_host_mcu`

Podsumowanie kroków:
- Przygotuj microSD z systemem dla BTT Pi (oficjalnie: obraz jak dla CB1)
- Zainstaluj Klipper na BTT Pi (host)
- Skompiluj i sflashuj firmware Klipper dla Artillery_Ruby-v1.2 (STM32F401)
- Skonfiguruj `printer.cfg` (użyj pliku `printer-artillery-sidewinder-x2-bttpi.cfg`)

1) Przygotowanie microSD

Pobierz oficjalny obraz z repo `CB1` (BTT podaje, że konfiguracja obrazu dla BTT Pi jest taka sama jak dla CB1), np.:
- `CB1_Debian13_Klipper_kernel7.0_20260430.img.xz`

Nagraj obraz na kartę microSD:

- Najprościej i najbezpieczniej: użyj `balenaEtcher` lub `Raspberry Pi Imager` (obsługują .xz bez ręcznej dekompresji).
- Jeśli wolisz `dd`, zdekompresuj strumieniowo i zapisz na urządzenie (bezpośrednie `dd` na .xz **nie** działa poprawnie):

```bash
# Uwaga: sprawdź device (np. /dev/sdX) zanim uruchomisz dd
xzcat CB1_Debian13_Klipper_kernel7.0_20260430.img.xz | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

Albo rozpakuj najpierw plik `.xz` i użyj `dd` na powstałym `.img`:

```bash
unxz CB1_Debian13_Klipper_kernel7.0_20260430.img.xz
sudo dd if=CB1_Debian13_Klipper_kernel7.0_20260430.img of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

2) Pierwsze uruchomienie i połączenie

- Włóż microSD do BTT Pi i uruchom. Połącz przez SSH (lub podłącz monitor/klawiaturę)
- Jeśli konfigurujesz Wi-Fi przed pierwszym startem, użyj pliku `system.cfg` na partycji BOOT, a nie `wpa_supplicant.conf`
- Zaktualizuj system:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git python3 python3-venv python3-dev build-essential libffi-dev libssl-dev
```

3) Instalacja Klipper (host) na BTT Pi

```bash
git clone https://github.com/Klipper3d/klipper.git
cd klipper
./scripts/install-octopi.sh || true
# Alternatywnie ręczna instalacja (instrukcje w docs/)
```

Uwaga: aby Klipper mógł sterować GPIO hosta (np. `host:gpio211`) wymagane są dodatkowe pakiety — zainstaluj `python3-rpi.gpio` oraz `python3-serial` (na Debian/CB1):

```bash
sudo apt update
sudo apt install -y python3-rpi.gpio python3-serial
```

4) Przygotowanie firmware dla Artillery board (STM32F401)

W katalogu `klipper`:

```bash
make menuconfig
# Ustawienia rekomendowane:
# - Micro-controller: STM32F401
# - Processor: STM32F401? (wybrać zgodnie z dokumentacją)
# - Bootloader: "No bootloader"
# - Communication interface: USB (PA11/PA12)

make
```

5) Flashowanie firmware na płytę Artillery_Ruby-v1.2

Instrukcja z oryginalnego pliku Klippera:

1. Ustaw fizyczny mostek między +3.3V i Boot0 na płycie Artillery_Ruby (opis w pliku oryginalnym/serwisowym)
2. Połącz drukarkę przez USB do BTT Pi
3. Uruchom:

```bash
# Przykładowa komenda flash (dopasuj device id):
make flash FLASH_DEVICE=/dev/serial/by-id/usb-Klipper_stm32f401xc_*-if00
```

Po poprawnym flashowaniu usuń mostek Boot0 i zrestartuj płytę.

6) Konfiguracja `printer.cfg`

- W katalogu z frontendem (np. Fluidd/Mainsail) wgraj plik `/home/pi/printer.cfg` równy zawartości:
- Użyj pliku: `/workspaces/drukarka3d/BTT-Pi/printer-artillery-sidewinder-x2-bttpi.cfg`

- Dopasuj w nim:
  - `[mcu] serial:` ustaw na rzeczywisty port urządzenia (np. `/dev/serial/by-id/usb-Klipper_stm32f401xc_...`)
  - Jeśli chcesz używać GPIO BTT Pi jako kontrolera dodatkowych urządzeń: użyj `host:gpioXXX` (w pliku jest `host:gpio211` dla wentylatora)
  - Na samej górze dodaj:

```ini
[include mainsail.cfg]
```

Uwaga dotycząca socketu host MCU:
- Aby `host:gpioNNN` działało, Klipper musi uruchamiać moduł "RPi microcontroller" który tworzy socket (np. `/tmp/klipper_host_mcu`). Postępuj zgodnie z dokumentacją Klippera: https://www.klipper3d.org/RPi_microcontroller.html i w razie potrzeby włącz serwis/skript tworzący socket. Po uruchomieniu systemu na BTT Pi sprawdź istnienie socketu:

```bash
ls -l /tmp/klipper_host_mcu
```

Jeżeli socket nie istnieje, sprawdź logi Klippera i instrukcję na stronie powyżej.

Uwaga praktyczna:
- `mainsail.cfg` musi być plikiem Klippera z sekcjami `[virtual_sdcard]`, `[pause_resume]`, `[display_status]` oraz makrami `PAUSE/RESUME/CANCEL_PRINT`.
- Sekcja `[mainsail]` nie jest poprawną sekcją Klippera i powoduje błąd parsowania.

7) Usługi i uruchomienie

```bash
# Uruchom/aktywuj serwisy Klipper (przykład systemd)
sudo cp ~/klipper/scripts/klipper.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now klipper
```

8) Testy i uruchomienie

- Sprawdź logi Klippera i połączenie z MCU:

```bash
sudo journalctl -u klipper -e
ls -l /dev/serial/by-id/
```

- Po wgraniu poprawnego `printer.cfg` wykonaj `TEST` i kalibracje: homing, PID tune, bed mesh.

Uwagi końcowe:
- Jeśli nie czujesz się komfortowo z mostkowaniem Boot0, możesz użyć programatora (ST-Link) do flashowania.
- Plik `printer-artillery-sidewinder-x2-bttpi.cfg` w repo zawiera dodatkową sekcję `temperature_fan raspberry_pi` która korzysta z `host:gpio211` (BTT Pi V1.2 fan pin).
