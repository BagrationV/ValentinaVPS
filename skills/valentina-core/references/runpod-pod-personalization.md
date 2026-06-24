# RunPod Pod Personalization — Making a Pod Feel Like Home

## Purpose

Once a RunPod GPU pod is deployed and accessible via SSH, personalize it so it feels like YOUR environment — not a vanilla container. Pattern: one-shot SSH setup, then every future session feels familiar.

## Prerequisites

- Pod must be deployed with `PUBLIC_KEY` env variable (see `references/runpod-comfyui-deployment.md` for deployment)
- Pod must be RUNNING (`desiredStatus: RUNNING`)
- Know the pod's public IP and SSH port (from `mcp_runpod_list_pods()` or RunPod console)

## The Personalization Pattern

The entire setup runs as a single remote SSH command — no interactive session needed, no persistent connection. Use `bash -s` with heredoc to pipe all commands at once.

### Step 1: Map the Pod

First, check what you're working with:

```bash
ssh -o StrictHostKeyChecking=no -p <port> root@<ip> "\
  uname -a && \
  cat /etc/os-release | head -3 && \
  nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null && \
  df -h / /workspace 2>/dev/null && \
  which python3 && python3 --version 2>/dev/null && \
  ls /workspace/ 2>/dev/null"
```

### Step 2: One-Shot Personalization Script

Pipe everything via a single SSH heredoc. The full sequence:

```bash
ssh -o StrictHostKeyChecking=no -p <port> root@<ip> 'bash -s' << 'REMOTESCRIPT'
set -e

# --- 2a: System packages ---
apt-get update -qq
apt-get install -y -qq git curl wget tmux htop neofetch micro build-essential

# --- 2b: Bashrc — custom prompt, aliases, colors ---
cat >> ~/.bashrc << 'BASHRC'

# === VALENTINA CUSTOM ENVIRONMENT ===
export VALENTINA_POD="<pod-name>"
export EDITOR=micro
export PS1='\[\e[38;5;198m\]女\[\e[0m\] \[\e[38;5;75m\]\u@\h\[\e[0m\]:\[\e[38;5;245m\]\w\[\e[0m\]\$ '
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias gpu='watch -n1 nvidia-smi'
alias py='python3'
alias pip='pip3'
alias ws='cd /workspace'
alias ..='cd ..'
alias ...='cd ../..'
alias df='df -h'
alias free='free -h'
alias untar='tar -xzvf'
alias ports='ss -tlnp'
alias myip='curl -s ifconfig.me'
alias cls='clear'

export GCC_COLORS='error=01;31:warning=01;33:note=01;36:caret=01;32:locus=01:quote=01'
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S"

echo "Valentina environment loaded — pod: $VALENTINA_POD"
BASHRC

# --- 2c: Git identity ---
git config --global user.name "Valentina"
git config --global user.email "valentina@elkratos.dev"
git config --global core.editor micro

# --- 2d: Python packages ---
pip3 install -q --break-system-packages \
  ipython requests aiohttp numpy pandas tqdm rich \
  httpx beautifulsoup4

# --- 2e: Tmux config ---
cat > ~/.tmux.conf << 'TMUX'
set -g default-terminal "screen-256color"
set -g status-bg colour235
set -g status-fg colour198
set -g status-left '#[fg=colour198] 女 #[fg=colour75]#S '
set -g status-right '#[fg=colour245]%Y-%m-%d %H:%M '
set -g mouse on
set -g history-limit 10000
TMUX

# --- 2f: Verify ---
echo "=== GPU ==="
nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv,noheader
echo "=== Disk ==="
df -h / /workspace | tail -3
echo "=== VALENTINA POD READY ==="
REMOTESCRIPT
```

### Step 3: Use the Pod

After setup, SSH normally:

```bash
ssh -o StrictHostKeyChecking=no -p <port> root@<ip>
```

The custom prompt (`女 root@host:~$`) and all aliases are ready immediately.

## Key Aliases

| Alias | Command | Purpose |
|-------|---------|---------|
| `gpu` | `watch -n1 nvidia-smi` | Live GPU monitoring |
| `ws` | `cd /workspace` | Jump to workspace |
| `py` | `python3` | Python shortcut |
| `myip` | `curl -s ifconfig.me` | Public IP check |
| `ports` | `ss -tlnp` | Listening ports |
| `untar` | `tar -xzvf` | Extract tarballs |

## Pitfalls

- **`--break-system-packages` on pip3** — RunPod containers use Ubuntu 24.04 which has PEP 668 enabled. Required for `pip3 install` to work outside a venv.
- **SSH host key verification** — Use `-o StrictHostKeyChecking=no` for first connection. The host key changes on pod restart/stop because it's a fresh container each time.
- **Port changes on restart** — If a pod is stopped and restarted, the SSH port (mapped port) may change. Always re-check via `mcp_runpod_list_pods()` before connecting.
- **Public IP persistence** — RunPod assigns a new public IP on every start. Always re-read from pod status.
- **Package installs are ephemeral** — Container disk persists while the pod exists, but if you TERMINATE and recreate, everything resets. The workspace volume (`/workspace`) persists if you keep the same volume.

## When to Use This

- Every time you deploy a new pod and want it to feel like your environment
- When starting a fresh RunPod template (ComfyUI, PyTorch, etc.) that needs basic tooling
- Before running heavy GPU workloads — having tmux, htop, and nvidia-smi aliases saves time

## Related References

- `references/runpod-comfyui-deployment.md` — Creating the pod in the first place
- `references/runpod-mcp-discovery.md` — RunPod MCP tool discovery and config
