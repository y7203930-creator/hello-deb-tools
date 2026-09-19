#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Ensure the script is run with root privileges
if [[ $EUID -ne 0 ]]; then
   echo "[-] Error: This setup script must be run with sudo or as root." >&2
   exit 1
fi

echo "===================================================="
echo "      DEBIAN CUSTOM UTILITIES SUITE INSTALLER       "
echo "===================================================="

# 1. Deploy deb-space
echo "[+] Deploying /usr/local/bin/deb-space..."
cat << 'EOF' > /usr/local/bin/deb-space
#!/usr/bin/env bash
if [[ $EUID -ne 0 ]]; then
   echo "[-] Error: This script must be run with sudo or as root." >&2
   exit 1
fi
echo "===================================================="
echo "          DEBIAN STORAGE AUDIT (deb-space)          "
echo "===================================================="
echo "[+] Analyzing major storage footprints..."
echo ""
APT_CACHE_SIZE=$(du -sh /var/cache/apt/archives 2>/dev/null | awk '{print $1}')
echo "-> APT Package Cache:     $APT_CACHE_SIZE"
LOG_SIZE=$(du -sh /var/log 2>/dev/null | awk '{print $1}')
echo "-> System Logs (/var/log): $LOG_SIZE"
if [ -d "$HOME/.cache" ]; then
    HOME_CACHE_SIZE=$(du -sh "$HOME/.cache" 2>/dev/null | awk '{print $1}')
    echo "-> User Cache (~/.cache):  $HOME_CACHE_SIZE"
fi
echo ""
echo "[+] Top 5 largest directories in /var:"
du -h --max-depth=1 /var 2>/dev/null | sort -hr | head -n 6
echo "===================================================="
EOF
chmod +x /usr/local/bin/deb-space

# 2. Deploy deb-kernels
echo "[+] Deploying /usr/local/bin/deb-kernels..."
cat << 'EOF' > /usr/local/bin/deb-kernels
#!/usr/bin/env bash
if [[ $EUID -ne 0 ]]; then
   echo "[-] Error: This script must be run with sudo or as root." >&2
   exit 1
fi
echo "===================================================="
echo "          DEBIAN KERNEL MANAGER (deb-kernels)       "
echo "===================================================="
CURRENT_KERNEL=$(uname -r)
echo "[*] Currently running kernel: $CURRENT_KERNEL"
echo ""
echo "[+] Installed kernel packages on this system:"
dpkg -l | grep -E "linux-image-[0-9]" | awk '{print $2, $3, $5}'
echo ""
read -p "Do you want to purge old, unused kernels using apt autoremove? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "[+] Cleaning up old kernels..."
    apt-get autoremove --purge -y
    echo "[+] Kernel cleanup complete."
else
    echo "[i] Skipped kernel cleanup."
fi
echo "===================================================="
EOF
chmod +x /usr/local/bin/deb-kernels

# 3. Deploy deb-fail
echo "[+] Deploying /usr/local/bin/deb-fail..."
cat << 'EOF' > /usr/local/bin/deb-fail
#!/usr/bin/env bash
if [[ $EUID -ne 0 ]]; then
   echo "[-] Error: This script must be run with sudo or as root." >&2
   exit 1
fi
echo "===================================================="
echo "          DEBIAN SECURITY LOG WATCH (deb-fail)      "
echo "===================================================="
echo "[+] Scanning system journal for recent authentication failures..."
if journalctl -u ssh -u sudo -u getty@* --since "24 hours ago" --priority=warning --no-pager 2>/dev/null | grep -iE "fail|error|invalid" ; then
    echo ""
    echo "[-] Notice: Review the warnings/failures listed above."
else
    echo "[+] No major authentication failures or service warnings found in the last 24 hours."
fi
echo "===================================================="
EOF
chmod +x /usr/local/bin/deb-fail

# 4. Deploy deb-help (Command Center & Developer Info)
echo "[+] Deploying /usr/local/bin/deb-help..."
cat << 'EOF' > /usr/local/bin/deb-help
#!/usr/bin/env bash
echo "===================================================="
echo "        DEBIAN CUSTOM SUITE - COMMAND CENTER        "
echo "===================================================="
echo ""
echo "Available Utilities:"
echo "  sudo deb-doc     - Run system health, integrity, and cache audit"
echo "  sudo deb-space   - Audit disk usage, caches, and log weights"
echo "  sudo deb-kernels - Inspect running/installed kernels and clean old versions"
echo "  sudo deb-fail    - Review recent authentication and service failures"
echo "  deb-help         - Display this help dashboard and developer info"
echo ""
echo "----------------------------------------------------"
echo "Developer Info:"
echo "  Dev:    hellojhon"
echo "  Roblox: https://www.roblox.com/users/7912177609/profile"
echo "===================================================="
EOF
chmod +x /usr/local/bin/deb-help

echo "===================================================="
echo "         SUITE INSTALLATION SUCCESSFUL              "
echo "===================================================="
echo "-> Type 'deb-help' anytime to view commands and developer info."
