#!/bin/bash
# Force-enable the quant_opcache module so hook_cache_flush() fires on
# config imports, drush cr, module install/uninstall, admin cache clears.
#
# Safe to run repeatedly (idempotent). Runs after Drupal is installed.
# If Drupal isn't bootstrapped yet (first-ever deploy, install in progress),
# exits cleanly without failing the container.
#
# Opt-out: create /var/www/html/.no-quant-opcache to skip this step.

set -uo pipefail

if [ -f /var/www/html/.no-quant-opcache ] || [ -f /opt/drupal/.no-quant-opcache ]; then
  echo "[quant-opcache] Opt-out flag present — skipping"
  exit 0
fi

# Drupal may not be installed yet on first boot. Exit cleanly if so.
if ! drush status --fields=bootstrap 2>/dev/null | grep -q "Successful"; then
  echo "[quant-opcache] Drupal not bootstrapped — skipping module enable (will run on next boot)"
  exit 0
fi

# Idempotent: skip if already enabled.
if drush pm:list --status=enabled --no-core --fields=name --format=list 2>/dev/null | grep -qx "quant_opcache"; then
  echo "[quant-opcache] Module already enabled"
  exit 0
fi

# Enable it. Log failure but don't crash the container.
if drush pm:enable quant_opcache -y 2>/dev/null; then
  echo "[quant-opcache] Module enabled"
else
  echo "[quant-opcache] Failed to enable module — continuing (will retry next boot)"
fi
