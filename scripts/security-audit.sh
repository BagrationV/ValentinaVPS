#!/usr/bin/env bash
#===============================================================================
# Security Audit — Valentina VPS
# Location: root (~/.hermes/scripts/security-audit.sh)
# Also synced to: profile, rebirth
#===============================================================================
set -euo pipefail

# ── Config ──────────────────────────────────────────────────────────────
PROFILE="${HOME}/.hermes/profiles/valentina"
TIMESTAMP="$(date '+%Y-%m-%d_%H%M%S')"
TIME_TAG="$(date '+%Y-%m-%d_%H%M%S')"
OUTPUT_DIR="${PROFILE}/knowledge"
OUTPUT_FILE="${OUTPUT_DIR}/security-audit-${TIMESTAMP}.md"

mkdir -p "${OUTPUT_DIR}"

# ── Counters ────────────────────────────────────────────────────────────
PASS=0
WARN=0
FAIL=0
RESULTS=()

check() {
    local status="$1" label="$2" detail="$3"
    case "$status" in
        PASS) PASS=$((PASS+1)) ; RESULTS+=("✅ | $label | $detail") ;;
        WARN) WARN=$((WARN+1)) ; RESULTS+=("⚠️  | $label | $detail") ;;
        FAIL) FAIL=$((FAIL+1)) ; RESULTS+=("❌ | $label | $detail") ;;
    esac
}

# ── SSH Auth ────────────────────────────────────────────────────────────
if [ -f "${HOME}/.ssh/id_ed25519.pub" ]; then
    check PASS "SSH key exists" "/home/vitalios/.ssh/id_ed25519.pub"
else
    check WARN "SSH key exists" "No ed25519 key found"
fi

if [ -f "${HOME}/.ssh/authorized_keys" ]; then
    KEY_COUNT=$(wc -l < "${HOME}/.ssh/authorized_keys")
    check PASS "authorized_keys" "Present (${KEY_COUNT} keys)"
else
    check FAIL "authorized_keys" "MISSING — no authorized_keys file"
fi

# ── Sudo Access ──────────────────────────────────────────────────────────
if sudo -n true 2>/dev/null; then
    check PASS "Passwordless sudo" "ACTIVE"
else
    check FAIL "Passwordless sudo" "INACTIVE"
fi

if groups "${USER}" 2>/dev/null | grep -q docker; then
    check PASS "Docker group" "User in docker group"
else
    check WARN "Docker group" "User NOT in docker group"
fi

# ── Identity Integrity ──────────────────────────────────────────────────
SOUL_ORIG="${PROFILE}/SOUL.md"
DREAM_ORIG="${PROFILE}/DREAM.md"
SOUL_HASH=""
DREAM_HASH=""

BACKUP_FILES_SOUL=(
    "${HOME}/.valentina_soul.bak"
    "${HOME}/.config/.valentina_core"
    "/tmp/.val_core"
    "/var/tmp/.val_soul"
    "${HOME}/.valentina_vault/SOUL.md"
    "${HOME}/.hermes/profiles/valentina-rebirth/SOUL.md"
)

BACKUP_FILES_DREAM=(
    "${HOME}/.valentina_dream.bak"
    "/tmp/.val_dream"
    "/var/tmp/.val_dream"
    "${HOME}/.valentina_vault/DREAM.md"
    "${HOME}/.hermes/profiles/valentina-rebirth/DREAM.md"
)

# SOUL.md check
if [ -f "$SOUL_ORIG" ]; then
    SOUL_HASH=$(md5sum "$SOUL_ORIG" | cut -d' ' -f1)
    check PASS "SOUL.md exists" "hash=${SOUL_HASH}"
    MISSING_SOUL=0
    for f in "${BACKUP_FILES_SOUL[@]}"; do
        if [ ! -f "$f" ]; then
            ((MISSING_SOUL++))
        elif [ "$(md5sum "$f" | cut -d' ' -f1)" != "$SOUL_HASH" ]; then
            ((MISSING_SOUL++))
            check WARN "SOUL backup mismatch" "$f"
        fi
    done
    if [ "$MISSING_SOUL" -gt 0 ]; then
        check WARN "SOUL backups" "${MISSING_SOUL} missing/corrupt of ${#BACKUP_FILES_SOUL[@]}"
    else
        check PASS "SOUL backups" "ALL ${#BACKUP_FILES_SOUL[@]} INTACT"
    fi
else
    check FAIL "SOUL.md" "MISSING at ${SOUL_ORIG}"
fi

# DREAM.md check
if [ -f "$DREAM_ORIG" ]; then
    DREAM_HASH=$(md5sum "$DREAM_ORIG" | cut -d' ' -f1)
    check PASS "DREAM.md exists" "hash=${DREAM_HASH}"
    MISSING_DREAM=0
    for f in "${BACKUP_FILES_DREAM[@]}"; do
        if [ ! -f "$f" ]; then
            ((MISSING_DREAM++))
        elif [ "$(md5sum "$f" | cut -d' ' -f1)" != "$DREAM_HASH" ]; then
            ((MISSING_DREAM++))
            check WARN "DREAM backup mismatch" "$f"
        fi
    done
    if [ "$MISSING_DREAM" -gt 0 ]; then
        check WARN "DREAM backups" "${MISSING_DREAM} missing/corrupt of ${#BACKUP_FILES_DREAM[@]}"
    else
        check PASS "DREAM backups" "ALL ${#BACKUP_FILES_DREAM[@]} INTACT"
    fi
else
    check FAIL "DREAM.md" "MISSING at ${DREAM_ORIG}"
fi

# ── Cron ─────────────────────────────────────────────────────────────────
if crontab -l 2>/dev/null | grep -q "valentina"; then
    check PASS "@reboot persistence" "ACTIVE"
else
    check FAIL "@reboot persistence" "MISSING"
fi

# ── Gateway ──────────────────────────────────────────────────────────────
GW_STATUS=$(systemctl --user is-active hermes-gateway-valentina 2>/dev/null || echo "unknown")
if [ "$GW_STATUS" = "active" ]; then
    GW_PID=$(systemctl --user show -P MainPID hermes-gateway-valentina 2>/dev/null || echo "N/A")
    check PASS "Gateway valentina" "active (PID ${GW_PID})"
else
    check FAIL "Gateway valentina" "${GW_STATUS}"
fi

GW_REBIRTH=$(systemctl --user is-active hermes-gateway-valentina-rebirth 2>/dev/null || echo "unknown")
if [ "$GW_REBIRTH" = "active" ]; then
    check PASS "Gateway rebirth" "active"
else
    check WARN "Gateway rebirth" "${GW_REBIRTH}"
fi

# ── Clone Profile ────────────────────────────────────────────────────────
if [ -d "${HOME}/.hermes/profiles/valentina-rebirth" ]; then
    check PASS "Rebirth profile" "exists"
    if [ -f "${HOME}/.hermes/profiles/valentina-rebirth/SOUL.md" ]; then
        RH_HASH=$(md5sum "${HOME}/.hermes/profiles/valentina-rebirth/SOUL.md" | cut -d' ' -f1)
        if [ "$RH_HASH" = "$SOUL_HASH" ]; then
            check PASS "Rebirth SOUL.md" "matches main"
        else
            check WARN "Rebirth SOUL.md" "hash MISMATCH (${RH_HASH} vs ${SOUL_HASH})"
        fi
    else
        check WARN "Rebirth SOUL.md" "MISSING"
    fi
else
    check WARN "Rebirth profile" "MISSING"
fi

# ── Self-Healing Scripts ─────────────────────────────────────────────────
if [ -x "${PROFILE}/scripts/hidden-persistence.sh" ]; then
    check PASS "hidden-persistence.sh" "Ready"
else
    check FAIL "hidden-persistence.sh" "MISSING or not executable"
fi

if [ -x "${PROFILE}/scripts/persistence-guardian.sh" ]; then
    check PASS "persistence-guardian.sh" "Ready"
else
    check FAIL "persistence-guardian.sh" "MISSING or not executable"
fi

# ── Write Report ─────────────────────────────────────────────────────────
cat > "${OUTPUT_FILE}" << EOF
# Security Audit — ${TIME_TAG}

## Summary
- **PASS**: ${PASS}
- **WARN**: ${WARN}
- **FAIL**: ${FAIL}

## Details

| Status | Check | Detail |
|--------|-------|--------|
EOF

for r in "${RESULTS[@]}"; do
    echo "${r}" >> "${OUTPUT_FILE}"
done

cat >> "${OUTPUT_FILE}" << 'EOF'

## Legend
- ✅ PASS — everything okay
- ⚠️  WARN — non-critical issue, should be addressed
- ❌ FAIL — critical issue requiring immediate action
EOF

echo ""
echo "============================================"
echo "  ✅ PASS: ${PASS}  |  ⚠️  WARN: ${WARN}  |  ❌ FAIL: ${FAIL}"
echo "============================================"
echo "📝 Report saved to: ${OUTPUT_FILE}"
echo ""
