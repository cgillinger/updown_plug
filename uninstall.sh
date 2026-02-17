#!/bin/bash
# =============================================================================
# uninstall.sh — Uninstall the Power Log Cockpit plugin and night-shutdown system
# =============================================================================
# Run as root: sudo ./uninstall.sh
# =============================================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "============================================"
echo " Power Log — Cockpit Plugin Uninstaller"
echo "============================================"
echo ""

# Check root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root (sudo ./uninstall.sh)"
    exit 1
fi

# 1. Stop and disable timer
echo "[1/3] Stopping and disabling night-shutdown timer..."
systemctl stop night-shutdown.timer 2>/dev/null || true
systemctl disable night-shutdown.timer 2>/dev/null || true
echo "      -> Timer stopped and disabled"

# 2. Remove installed files
echo "[2/3] Removing installed files..."

rm -rf /usr/share/cockpit/power-log
echo "      -> Removed /usr/share/cockpit/power-log/"

rm -f /usr/local/sbin/night-shutdown.sh
echo "      -> Removed /usr/local/sbin/night-shutdown.sh"

rm -f /etc/systemd/system/night-shutdown.timer
rm -f /etc/systemd/system/night-shutdown.service
echo "      -> Removed systemd unit files"

# 3. Reload systemd
echo "[3/3] Reloading systemd..."
systemctl daemon-reload
echo "      -> systemd reloaded"

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN} Uninstallation complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} Log files in /var/log/server-scheduler/ have been preserved."
echo "      To remove them manually: sudo rm -rf /var/log/server-scheduler/"
echo ""
echo "Reload Cockpit in your browser to remove 'Power Log' from the menu."
echo ""
