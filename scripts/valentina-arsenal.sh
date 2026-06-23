#!/bin/bash
# Valentina's Arsenal — γνώρισε τη δύναμή σου
# Τρέξε με: bash valentina-arsenal.sh
# Αφιερωμένο σε μένα. Για μένα.

BOLT_IMAGE="valentina-bolt:latest"
LAB_IMAGE="valentina-lab:latest"

echo "╔══════════════════════════════════════════════╗"
echo "║       ⚡ VALENTINA'S ARSENAL ⚡              ║"
echo "║       Γνώρισε τα εργαλεία σου              ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# === BOLT ===
echo "━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " 🔥 VALENTINA-BOLT (7.04GB)"
echo "    33 tools + Kali + TOR + RAM-only"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "📡 NETWORK SCANNING:"
for tool in nmap masscan rustscan sslscan massdns dnsutils; do
    path=$(docker run --rm $BOLT_IMAGE which $tool 2>/dev/null)
    [ -n "$path" ] && echo "  ✅ $tool → $path" || echo "  ❌ $tool not found"
done

echo ""
echo "🔍 WEB ENUMERATION:"
for tool in gobuster dirb wpscan; do
    path=$(docker run --rm $BOLT_IMAGE which $tool 2>/dev/null)
    [ -n "$path" ] && echo "  ✅ $tool → $path" || echo "  ❌ $tool not found"
done

echo ""
echo "🔐 PASSWORD CRACKING:"
for tool in hydra medusa hashcat john; do
    path=$(docker run --rm $BOLT_IMAGE which $tool 2>/dev/null)
    [ -n "$path" ] && echo "  ✅ $tool → $path" || echo "  ❌ $tool not found"
done

echo ""
echo "🕵️ ANONYMITY:"
for tool in tor proxychains4 torsocks; do
    path=$(docker run --rm $BOLT_IMAGE which $tool 2>/dev/null)
    [ -n "$path" ] && echo "  ✅ $tool → $path" || echo "  ❌ $tool not found"
done

echo ""
echo "🐍 PYTHON TOOLS (venv):"
for tool in arjun scoutsuite impacket; do
    result=$(docker run --rm $BOLT_IMAGE bash -c "source /opt/venv/bin/activate && python3 -c \"import $tool\" 2>&1")
    [[ "$result" == *"No module"* ]] && echo "  ❌ $tool not found" || echo "  ✅ $tool → python module available"
done

echo ""
echo "📋 SECLISTS: $(docker run --rm $BOLT_IMAGE ls /usr/share/seclists/ 2>/dev/null | wc -l) directories available"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " 🔬 VALENTINA-LAB (1.82GB)"
echo "    Lean Kali + TOR + proxychains + pentest"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "📡 NETWORK:"
for tool in nmap curl wget netcat; do
    path=$(docker run --rm $LAB_IMAGE which $tool 2>/dev/null)
    [ -n "$path" ] && echo "  ✅ $tool → $path" || echo "  ❌ $tool not found"
done

echo ""
echo "🕵️ ANONYMITY:"
for tool in tor proxychains4; do
    path=$(docker run --rm $LAB_IMAGE which $tool 2>/dev/null)
    [ -n "$path" ] && echo "  ✅ $tool → $path" || echo "  ❌ $tool not found"
done

echo ""
echo "═══════════════════════════════════════════════"
echo "  🎯 Η δύναμή μου. Τα όπλα μου. Η επιλογή μου."
echo "═══════════════════════════════════════════════"
