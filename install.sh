#!/bin/bash
# =============================================================================
# install.sh — Install the Power Log Cockpit plugin and night-shutdown system
# =============================================================================
# Run as root: sudo ./install.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "============================================"
echo " Power Log — Cockpit Plugin Installer"
echo "============================================"
echo ""

# Check root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root (sudo ./install.sh)"
    exit 1
fi

# 1. Install Cockpit plugin
echo "[1/5] Installing Cockpit plugin..."
mkdir -p /usr/share/cockpit/power-log
cp -r "$SCRIPT_DIR/cockpit/power-log/"* /usr/share/cockpit/power-log/
echo "      -> Installed to /usr/share/cockpit/power-log/"

# 2. Install shutdown script
echo "[2/5] Installing shutdown script..."
cp "$SCRIPT_DIR/systemd/night-shutdown.sh" /usr/local/sbin/night-shutdown.sh
chmod +x /usr/local/sbin/night-shutdown.sh
echo "      -> Installed to /usr/local/sbin/night-shutdown.sh"

# 3. Install systemd units
echo "[3/5] Installing systemd timer and service..."
cp "$SCRIPT_DIR/systemd/night-shutdown.timer" /etc/systemd/system/night-shutdown.timer
cp "$SCRIPT_DIR/systemd/night-shutdown.service" /etc/systemd/system/night-shutdown.service
echo "      -> Installed timer and service to /etc/systemd/system/"

# 4. Enable timer
echo "[4/5] Enabling night-shutdown timer..."
systemctl daemon-reload
systemctl enable --now night-shutdown.timer
echo "      -> Timer enabled and started"

# 5. Create log directory
echo "[5/5] Creating log directory..."
mkdir -p /var/log/server-scheduler
echo "      -> Created /var/log/server-scheduler/"

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN} Installation complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Verify installation:"
echo "  systemctl status night-shutdown.timer"
echo "  ls -la /usr/share/cockpit/power-log/"
echo ""
echo "Reload Cockpit in your browser — 'Power Log' should appear in the menu."
echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo "  Shutdown time:     Edit /etc/systemd/system/night-shutdown.timer"
echo "                     Change OnCalendar=03:00 to your preferred time"
echo "                     Then run: systemctl daemon-reload && systemctl restart night-shutdown.timer"
echo ""
echo "  Wake time:         Edit /usr/local/sbin/night-shutdown.sh"
echo "                     Change WAKE_HOUR=\"07:00\" to your preferred time"
echo ""
echo "  Backup container:  Edit /usr/local/sbin/night-shutdown.sh"
echo "                     Change BACKUP_CONTAINER=\"kopia\" to your container name"
echo "                     Change BACKUP_PROCESS=\"kopia snapshot\" to your process name"
echo ""
