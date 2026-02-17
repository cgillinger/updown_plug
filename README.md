# Power Log — Cockpit Plugin

A Cockpit plugin that displays server shutdown/wake history and nightly backup status in a clean dashboard.

![Screenshot placeholder](screenshot.png)

## Requirements

- Ubuntu/Debian with systemd
- [Cockpit](https://cockpit-project.org/) installed and running
- Docker (optional — only needed for backup process detection)
- `rtcwake` (part of `util-linux`, usually pre-installed)

## Installation

```bash
git clone https://github.com/your-user/cockpit-power-log.git
cd cockpit-power-log
sudo ./install.sh
```

After installation, reload Cockpit in your browser. **Power Log** will appear in the left-side menu.

### Verify

```bash
systemctl status night-shutdown.timer
ls -la /usr/share/cockpit/power-log/
```

## How It Works

1. A **systemd timer** (`night-shutdown.timer`) triggers at a configurable time (default 03:00).
2. The **shutdown script** checks if a backup process (e.g., Kopia in Docker) is running.
   - If a backup is active, shutdown is **cancelled** and the event is logged.
   - If no backup is running, the server sets an **RTC wake alarm** and powers off.
3. The server **wakes automatically** at the configured time (default 07:00) via RTC.
4. The **Cockpit plugin** reads boot history from `journalctl` and the power log file, presenting everything in a clear dashboard.

### Dashboard Sections

- **Summary banner** — Last shutdown, last wake, overall status, next scheduled shutdown.
- **Boot/Shutdown history** — Table with boot time, shutdown time, uptime, and wake type classification (RTC wake / immediate wake / manual).
- **Power log** — Parsed entries from `/var/log/server-scheduler/power.log` showing each nightly cycle with status.

## Configuration

### Shutdown time

Edit the systemd timer:

```bash
sudo systemctl edit night-shutdown.timer
```

Override the `OnCalendar` value:

```ini
[Timer]
OnCalendar=02:30
```

Then reload:

```bash
sudo systemctl daemon-reload && sudo systemctl restart night-shutdown.timer
```

Or edit `/etc/systemd/system/night-shutdown.timer` directly.

### Wake time

Edit `/usr/local/sbin/night-shutdown.sh` and change:

```bash
WAKE_HOUR="07:00"
```

### Backup container

Edit `/usr/local/sbin/night-shutdown.sh` and change:

```bash
BACKUP_CONTAINER="kopia"
BACKUP_PROCESS="kopia snapshot"
```

If Docker is not installed or the container doesn't exist, the backup check is skipped and shutdown proceeds normally.

## Uninstallation

```bash
sudo ./uninstall.sh
```

This removes all installed files but **preserves log files** in `/var/log/server-scheduler/`. Remove them manually if desired.

## File Structure

```
cockpit-power-log/
├── README.md
├── install.sh
├── uninstall.sh
├── cockpit/
│   └── power-log/
│       ├── manifest.json
│       └── index.html
├── systemd/
│   ├── night-shutdown.timer
│   ├── night-shutdown.service
│   └── night-shutdown.sh
└── LICENSE
```

## License

MIT — see [LICENSE](LICENSE).
