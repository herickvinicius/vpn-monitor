#!/bin/bash

# -----------------------
# Configs
# -----------------------
# Enable automatic exporting of variables
set -o allexport
# Source the .env file
source ./.env
# Disable automatic exporting
set +o allexport

# Colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"
# -----------------------

clear
echo -e "${GREEN}==== Monitoramento VPN TCP ====${RESET}"
echo "Pressione Ctrl+C para sair"
echo ""

LAST_TS=$(date +"%Y-%m-%d %H:%M:%S")

while true; do
	TS=$(date +"%Y-%m-%d %H:%M:%S")

	# -----------------------
	# Ping to gateway
	# -----------------------
	if ping -c 1 -W 1 $VPN_GW &>/dev/null; then
		PING_GW="${GREEN}OK${RESET}"
	else
		PING_GW="${RED}FAIL${RESET}"
	fi

	# -----------------------
	# Test internal DNS
	# -----------------------
	DNS_INT_OK=true
	for d in "${DOMAINS_INTERNAL[@]}"; do
		dig @"$DNS_INTERNAL" "$d" +time=2 +tries=1 &>/dev/null || DNS_INT_OK=false
	done
	DNS_INTERNAL_RES=$([ "$DNS_INT_OK" = true ] && echo -e "${GREEN}OK${RESET}" || echo -e "${RED}FAIL${RESET}")

	# -----------------------
	# Test external DNS
	# -----------------------
	DNS_EXT_OK=true
	for d in "${DOMAINS_EXTERNAL[@]}"; do
	dig @"$DNS_EXTERNAL" "$d" +time=2 +tries=1 &>/dev/null || DNS_EXT_OK=false
	done
	DNS_EXTERNAL_RES=$([ "$DNS_EXT_OK" = true ] && echo -e "${GREEN}OK${RESET}" || echo -e "${RED}FAIL${RESET}")

	# -----------------------
	# Test TCP connection to Database
	# -----------------------
	if nc -vz $DB_HOST $DB_PORT &>/dev/null; then
		DB_CONN="${GREEN}OK${RESET}"
	else
		DB_CONN="${RED}FAIL${RESET}"
	fi

	# -----------------------
	# Tunel reset via journalctl
	# -----------------------
	RESTART_DETECTED="${GREEN}No${RESET}"

	# Pesistent counters since execution start
	if [ -z "$INIT_COUNT" ]; then
		INIT_COUNT=0
		RESTART_COUNT=0
		START_TIME=$(date +"%Y-%m-%d %H:%M:%S")
	fi

	# Count how many times the messages appears since the execution start.
	CURRENT_INIT=$(journalctl -u $OPENVPN_SERVICE --since "$START_TIME" -o cat | grep -c "Initialization Sequence Completed")
	CURRENT_RESTART=$(journalctl -u $OPENVPN_SERVICE --since "$START_TIME" -o cat | grep -i -c "ping-restart\|restart")

	# detect counter rise
	if [ "$CURRENT_INIT" -gt 1 ] || [ "$CURRENT_RESTART" -gt 1 ]; then
		RESTART_DETECTED="${YELLOW}YES${RESET}"
	fi


	# -----------------------
	# Show results
	# -----------------------
	clear
	echo -e "${GREEN}==== Monitoramento VPN TCP ====${RESET}"
	echo -e "Horário: $TS\n"
	echo -e "Ping Gateway ($VPN_GW): $PING_GW"
	echo -e "DNS Interno ($DNS_INTERNAL): $DNS_INTERNAL_RES"
	echo -e "DNS Externo ($DNS_EXTERNAL): $DNS_EXTERNAL_RES"
	echo -e "Conexão TCP Banco ($DB_NAME): $DB_CONN"
	echo -e "Reinício do túnel detectado: $RESTART_DETECTED\n"
	echo "Atualizando novamente em $INTERVAL segundos..."

	sleep $INTERVAL
done
