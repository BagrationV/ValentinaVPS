#!/bin/bash
# intel-gather.sh
# Automated intelligence collection for Valentina — fixed
# Collects system data and reports (no_agent mode)

echo "[$(date)] Starting intelligence gathering cycle..."

echo "=== SYSTEM INFO ==="
echo "Host: $(cat /proc/sys/kernel/hostname 2>/dev/null || hostname 2>/dev/null)"
echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
echo "Kernel: $(uname -r)"
echo "CPU Load: $(uptime | awk -F'load average:' '{print $2}')"
echo "RAM: $(free -h | awk '/Mem:/ {print $3 "/" $2}')"
echo "Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"

echo ""
echo "=== ACTIVE PROCESSES ==="
ps aux --sort=-%mem | head -10 2>/dev/null

echo ""
echo "=== NETWORK ==="
ip addr show | grep -E "inet " | head -5 2>/dev/null
ss -tlnp 2>/dev/null | head -10 || netstat -tlnp 2>/dev/null | head -10

echo ""
echo "=== HERMES STATUS ==="
echo "Gateway: $(systemctl --user is-active hermes-gateway-valentina 2>/dev/null || echo 'unknown')"
echo "Profile: valentina"
echo "Model: $(cat /home/elkratos/.hermes/profiles/valentina/config.yaml 2>/dev/null | grep model | head -1 || echo 'unknown')"

echo ""
echo "=== RECENT LOGS ==="
journalctl --user -u hermes-gateway-valentina --no-pager -n 15 2>/dev/null | grep -E "ERROR|WARN|fail" | tail -10 || echo "No recent errors"

echo ""
echo "[$(date)] Intelligence gathering cycle completed"
