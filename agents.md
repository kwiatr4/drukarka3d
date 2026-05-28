# Agents / SSH shortcuts

Zapis skrótu do połączenia SSH i przykładowych komend dla drukarki (BTT Pi).

- `ssh_shortcut`: biqu@192.168.1.12
- `remote_config_path`: /home/biqu/printer_data/config/printer.cfg

Przykładowe komendy (uruchom na laptopie w PowerShell / terminalu):

1) Połączenie SSH:

```bash
ssh biqu@192.168.1.12
```

2) Kopiowanie scalonego pliku konfiguracji na Pi (z katalogu repo lokalnego):

```bash
# użyj cudzysłowów przy ścieżkach zawierających spacje
scp "EP3D SWX2 Klipper Configs and Firmware/Klipper/Configs/Merged/printer-artillery-sidewinder-x2-bttpi.cfg" biqu@192.168.1.12:/home/biqu/printer_data/config/printer.cfg.new
```

3) Na Pi: backup i zamiana pliku (po zalogowaniu lub przez ssh):

```bash
mkdir -p /home/biqu/printer_data/config/backup
cp /home/biqu/printer_data/config/printer.cfg /home/biqu/printer_data/config/backup/printer.cfg.$(date +%Y%m%d_%H%M) 2>/dev/null || true
mv /home/biqu/printer_data/config/printer.cfg.new /home/biqu/printer_data/config/printer.cfg
chown biqu:biqu /home/biqu/printer_data/config/printer.cfg
chmod 644 /home/biqu/printer_data/config/printer.cfg
```

4) Restart Klipper i sprawdzenie logów:

```bash
sudo systemctl restart klipper
sudo journalctl -u klipper -n 200 --no-pager
# opcjonalnie
sudo systemctl restart moonraker
sudo journalctl -u moonraker -n 200 --no-pager
```

Uwaga: zaktualizuj `agents.md`, jeśli adres IP lub użytkownik się zmienią.

---

**Network / workflow note**

- Development: working in GitHub Codespace (cloud). Codespace cannot directly access devices on your local LAN (e.g. 192.168.x.x).
- Local laptop: present and in the same LAN as the printer. Use the laptop to copy files directly to the Pi with `scp`, or push changes from Codespace to GitHub and perform `git pull` on the Pi.
- Recommended flow:
	1. Edit files in Codespace and `git push` to your repo.
	2. On the laptop (or on the Pi), run `git pull` in `/home/biqu/drukarka3d` and then copy the desired config into `/home/biqu/printer_data/config` (or use the provided `deploy_config_to_pi.sh`).
	3. Restart Klipper: `sudo systemctl restart klipper` and verify logs: `sudo journalctl -u klipper -n 200 --no-pager`.

This avoids attempting `scp` directly from Codespace to a private LAN IP, which will fail.

---

**Merged printer config**

- Final merged file name: `printer-artillery-sidewinder-x2-bttpi.cfg`
- Location in repo: `EP3D SWX2 Klipper Configs and Firmware/Klipper/Configs/Merged/printer-artillery-sidewinder-x2-bttpi.cfg`
- Purpose: merged Sidewinder X2 config based on EP3D stock + BTT Pi host settings, intended to be copied as `printer.cfg` on the printer.
- Deployment target on printer: `/home/biqu/printer_data/config/printer.cfg`
- In practice this is the final Sidewinder X2 + BTT Pi config we want to keep using and update from the repo.