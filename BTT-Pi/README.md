# BTT-Pi / Sidewinder X2 notes

This folder contains the working Klipper/Mainsail setup for Artillery Sidewinder X2 on BIGTREETECH Pi V1.2.

Current working pieces:
- `printer-artillery-sidewinder-x2-bttpi.cfg` - adapted printer config for the Artillery_Ruby-v1.2 board
- `mainsail.cfg` - Klipper-compatible helper config for Mainsail UI
- `INSTALL-Klipper-BTT-Pi.md` - installation and flashing notes
- `SETUP_NOTES.md` - quick project summary and useful commands

Important details:
- Add `[include mainsail.cfg]` at the top of `printer.cfg`
- The host fan uses BTT Pi V1.2 GPIO mapping `host:gpio211`
- Host socket for `host:gpio` support is `/tmp/klipper_host_mcu`

Reference links:
- CB1 / image notes: https://github.com/bigtreetech/cb1
- BTT Pi V1.2 fan pin: https://github.com/bigtreetech/BTT-Pi/blob/master/BIGTREETECH%20Pi%20V1.2%20-%20Board%20Fan%20Pin%20Configuration
