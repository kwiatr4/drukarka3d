## BTT Pi / Sidewinder X2 — Notatki instalacyjne

Krótki opis: ten plik zbiera kroki, polecenia i lokalizacje plików użyte podczas konfiguracji Klippera na BTT Pi V1.2 pod drukarkę Artillery Sidewinder X2.

UWAGA: nie zapisuję żadnych haseł w repo. Hasła i inne sekretne dane powinny być przechowywane poza repozytorium (np. menedżer haseł, `secrets` na hostach, lub zaszyfrowany plik lokalny).

Sprzęt:
- Drukarka: Artillery Sidewinder X2
- Host: BIGTREETECH Pi V1.2 (CB1 style image)

Użytkownicy/hasła:
- Główny użytkownik systemowy użyty do połączeń: `biqu` (konto systemowe na BTT Pi)
- Hasło: NIE ZAPISANE (dopisz lokalnie poza repo jeśli chcesz — NIE committuj haseł)

Pliki i ścieżki istotne:
- Główna konfiguracja Mainsail: `/home/biqu/printer_data/config/mainsail.cfg` (w repo: `BTT-Pi/mainsail.cfg`)
- Symlink używany na urządzeniu: `/home/biqu/printer_data/config/mainsail.cfg -> /home/biqu/mainsail-config/mainsail.cfg`
- Printer config: `/home/biqu/printer_data/config/printer.cfg` (UI Machine → Upload)
- Host socket wymagany dla `host:gpio` pinów: `/tmp/klipper_host_mcu`

Adresy / sieć:
- IP BTT Pi: (wstaw lokalny IP tutaj, np. `192.168.1.12`)
- Dostęp do UI: http://<IP_BTT_PI> (Mainsail/Fluidd)

Szybkie polecenia (SSH na BTT Pi):
- Połączenie:
```bash
ssh biqu@<IP_BTT_PI>
```
- Sprawdź plik mainsail.cfg i zawartość celu symlinku:
```bash
ls -l /home/biqu/printer_data/config/mainsail.cfg
ls -l /home/biqu/mainsail-config/mainsail.cfg
sed -n '1,240p' /home/biqu/mainsail-config/mainsail.cfg
```
- Restart Moonraker i status:
```bash
sudo systemctl restart moonraker
sudo systemctl status moonraker --no-pager -l
```
- Sprawdź porty MCU:
```bash
ls -l /dev/serial/by-id/ || ls -l /dev/ttyACM* /dev/ttyUSB*
```
- Sprawdź socket host MCU:
```bash
ls -l /tmp/klipper_host_mcu
```

Co zostało wykonane (podsumowanie):
- Przygotowano plik `BTT-Pi/mainsail.cfg` zawierający makra `PAUSE/RESUME/CANCEL_PRINT` i ustawienia UI.
- Skopiowano/udostępniono `mainsail.cfg` na BTT Pi (cel w `/home/biqu/mainsail-config/mainsail.cfg`).
- Sprawdzono istnienie symlinku i nadpisanie pliku przez sesję SSH/UI (jeśli UI użyto do wklejenia).
- Dostosowano `printer-artillery-sidewinder-x2-bttpi.cfg` aby używał `host:gpio211` dla wentylatora i dodałem `[mcu host] serial: /tmp/klipper_host_mcu` aby rozwiązać konflikt dostępu do portu.

Gdzie szukać historii poleceń / pomocnych plików:
- Repo lokalne z plikami konfiguracyjnymi: root repo `BTT-Pi/` (zawiera `printer-artillery-sidewinder-x2-bttpi.cfg`, `INSTALL-Klipper-BTT-Pi.md`, `download_mainsailos.sh`, `mainsail.cfg`)
- Na samym BTT Pi: `/home/biqu/printer_data/config/` oraz `/home/biqu/mainsail-config/` (jeśli użyty)

Bezpieczeństwo / uwagi końcowe:
- NIE committuj haseł ani plików binarnych z hasłami/publicznymi certyfikatami.
- Jeżeli chcesz faktycznie przechować hasła w repo, zamiast tego rozważ użycie zaszyfrowanego pliku (sops/age/gpg) lub GitHub Secrets (do CI) — mogę pomóc z implementacją takiego rozwiązania.

Jeśli chcesz, dodać do repo także kopię `mainsail.cfg` (zawartość obecna w pliku `BTT-Pi/mainsail.cfg`) — zrobiono to w tym commicie.

-- koniec
