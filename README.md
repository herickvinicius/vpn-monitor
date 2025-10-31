# 🛰️ VPN Monitor Script

A lightweight **Bash-based VPN monitoring tool** that continuously checks the health of your VPN connection and related network services — such as gateway reachability, internal/external DNS resolution, and database connectivity.  
It’s also capable of detecting **VPN tunnel restarts** by parsing `journalctl` logs for your OpenVPN client service.

---

## ⚙️ Features

✅ **Ping check** to your VPN gateway  
✅ **Internal & external DNS resolution tests** (using `dig`)  
✅ **Database TCP connection check** (using `nc`)  
✅ **Detection of VPN tunnel restarts** (`journalctl` log monitoring)  
✅ **Color-coded terminal output** for quick status reading  
✅ **Auto-refresh loop** with customizable intervals

---

## 🧩 Requirements

Make sure you have the following installed:

- **Bash** (v4+)
- **dig** (from `dnsutils` package)
- **nc / netcat**
- **journalctl** (systemd)
- **OpenVPN client** (or compatible service)

---

## 🗂️ Setup

1. **Clone this repository**

   ```bash
   git clone https://github.com/herickvinicius/vpn-monitor.git
   cd vpn-monitor
   ```

2. **Configure environment variables**

   Copy the example environment file:

   ```bash
   cp .env.example .env
   ```

   Then edit `.env` with your preferred editor (e.g. `nano .env`):

   ```bash
   VPN_GW="" # This is the VPN gateway IP (e.g. 10.8.0.1).
   DNS_INTERNAL="" # Internal DNS server IP (e.g. 10.20.0.2).
   DNS_EXTERNAL="" # External DNS server IP (e.g. 8.8.8.8).

   DOMAINS_INTERNAL=("database.internal.domain" "internal.domain1") # Adjust as needed.
   DOMAINS_EXTERNAL=("google.com" "cloudflare.com") # You can add more domains.

   DB_HOST="database.internal.domain" # Test connection to a database on the remote network.
   DB_NAME="database-name"
   DB_PORT=5432

   INTERVAL=30
   OPENVPN_SERVICE="openvpn-client@client.service" # Adjust to your systemd service.
   ```

3. **Make the script executable**

   ```bash
   chmod +x vpn-monitor.sh
   ```

4. **Run the monitor**

   ```bash
   ./vpn-monitor.sh
   ```

---

## 🖥️ Output Example

```
==== Monitoramento VPN TCP ====
Horário: 2025-10-31 15:04:12

Ping Gateway (10.8.0.1): OK
DNS Interno (10.20.0.2): OK
DNS Externo (8.8.8.8): OK
Conexão TCP Banco (database-name): OK
Reinício do túnel detectado: No

Atualizando novamente em 30 segundos...
```

---

## 🧠 How It Works

- Loads configuration from the `.env` file
- Continuously:
  - Pings your VPN gateway
  - Resolves internal and external domains
  - Tests TCP connectivity to your database
  - Scans `journalctl` logs for OpenVPN restarts
- Displays a color-coded dashboard that updates every `INTERVAL` seconds

---

## 🧩 Customization

You can monitor **any TCP-based service**, not just a database.  
For example, to check an internal web server instead of PostgreSQL:

```bash
DB_HOST="intranet.internal"
DB_PORT=80
DB_NAME="Internal Web"
```

---

## ⚠️ Notes

- Designed for **Linux systems with systemd** (Pop!_OS, Ubuntu, Debian, etc.).
- The script **does not restart the VPN** — it only detects issues.
- Run with appropriate permissions if your OpenVPN logs require elevated access.

---

## 🪪 License

MIT License © 2025 — Herick Vinicius

---

## 🤝 Contributions

Feel free to open issues or pull requests!  
Suggestions for new checks (HTTP, latency, packet loss, etc.) are welcome.
