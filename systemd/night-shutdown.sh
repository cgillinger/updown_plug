#!/bin/bash
# =============================================================================
# night-shutdown.sh — Nightly controlled shutdown with RTC wake
# =============================================================================
# This script is executed by night-shutdown.service (triggered by night-shutdown.timer).
# It checks for active backup processes before shutting down and sets an RTC alarm
# to wake the server at the configured time.
#
# Configurable variables:
#   WAKE_HOUR       — Time to wake the server (default: 07:00)
#   LOGDIR          — Directory for power logs
#   BACKUP_CONTAINER — Docker container name running backups (default: kopia)
#   BACKUP_PROCESS   — Process name to check inside the container (default: kopia snapshot)
# =============================================================================

# --- Configuration -----------------------------------------------------------
WAKE_HOUR="07:00"
LOGDIR="/var/log/server-scheduler"
LOGFILE="$LOGDIR/power.log"
BACKUP_CONTAINER="kopia"
BACKUP_PROCESS="kopia snapshot"
# -----------------------------------------------------------------------------

mkdir -p "$LOGDIR"

echo "----" >> "$LOGFILE"
echo "$(date '+%Y-%m-%d %H:%M:%S %Z') - Shutdown sequence initiated" >> "$LOGFILE"

# Check for active backup (only if Docker is available)
if command -v docker &>/dev/null; then
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^${BACKUP_CONTAINER}$"; then
        if docker exec "$BACKUP_CONTAINER" pgrep -f "$BACKUP_PROCESS" >/dev/null 2>&1; then
            echo "$(date '+%Y-%m-%d %H:%M:%S %Z') - ABORT: Backup activity detected (${BACKUP_CONTAINER}). Shutdown cancelled." >> "$LOGFILE"
            exit 0
        fi
    fi
fi

echo "$(date '+%Y-%m-%d %H:%M:%S %Z') - No active backup process detected" >> "$LOGFILE"

# Calculate next wake time
WAKE_TIME=$(date -d "tomorrow ${WAKE_HOUR}" +%s)
echo "$(date '+%Y-%m-%d %H:%M:%S %Z') - Wake set for next ${WAKE_HOUR} (epoch $WAKE_TIME)" >> "$LOGFILE"
echo "$(date '+%Y-%m-%d %H:%M:%S %Z') - Powering off (rtcwake -m off)" >> "$LOGFILE"

# Atomic: set RTC alarm + poweroff in one step
rtcwake -m off -t "$WAKE_TIME"
