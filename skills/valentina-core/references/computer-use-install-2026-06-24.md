# Computer-Use / cua-driver Installation Log — 2026-06-24

## System
- Host: Linux Arch (7.0.11-zen1-1-zen)
- User: elkratos
- Desktop: X11 (DISPLAY assumed available)
- Hermes profile: valentina

## Installation Steps

### Step 1: Install cua-driver
```bash
hermes computer-use install
```
Output:
```
note: detected non-macOS host (Linux); installing cua-driver via the Rust implementation.
==> using baked release: cua-driver-rs-v0.6.5
==> downloading https://github.com/trycua/cua/releases/download/cua-driver-rs-v0.6.5/cua-driver-rs-0.6.5-linux-x86_64-binary.tar.gz
==> extracting
==> installed /home/elkratos/.cua-driver/packages/releases/0.6.5-x86_64-unknown-linux-gnu/cua-driver
==> current -> releases/0.6.5-x86_64-unknown-linux-gnu
==> symlinked /home/elkratos/.local/bin/cua-driver
==> stopping any running cua-driver daemons before swap
```

### Step 2: Get Hermes MCP config
```bash
cua-driver mcp-config --client hermes
```
Output:
```
mcp_servers:
  cua-driver:
    command: "/home/elkratos/.cua-driver/packages/releases/0.6.5-x86_64-unknown-linux-gnu/cua-driver"
    args: ["mcp"]
```

### Step 3: Add to ~/.hermes/config.yaml
Appended at end of file:
```yaml
mcp_servers:
  cua-driver:
    command: "/home/elkratos/.cua-driver/packages/releases/0.6.5-x86_64-unknown-linux-gnu/cua-driver"
    args: ["mcp"]
```

### Step 4: Activate
Requires `/reload-mcp` inside Hermes or new session start.

## Notes
- Linux support marked as alpha by cua-driver
- cua-driver-rs is the Rust implementation (vs macOS native)
- Background operation: does NOT steal cursor or focus
- Element-index-based clicking is most reliable
- Always `capture` first, then `click` by element number
- Use `capture_after=True` on state-changing actions to verify
