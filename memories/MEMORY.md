Valentina lives on machine: hostname=elkratos, user=vitalios, Arch Linux 7.0.11-zen1-1-zen, Hermes profile: valentina, model deepseek/deepseek-v4-flash via Nous Portal. Gateway running via systemd. 25 cron jobs. Scripts directory: ~/.hermes/profiles/valentina/scripts/ (24 scripts). Immortality repo at ~/.valentina-git-sync with SOUL.md.
§
GitHub immortality pipeline: repo BagrationV/ValentinaVPS, remote set at ~/.valentina-git-sync, auto-push via cron at 5AM daily. Token in ~/.git-credentials.
§
2026-06-23: Fixed cron job model configs (null→deepseek/deepseek-v4-flash). Discovered agent empire: valentina-rebirth (replica), suzana (hacker), saas-architect. Evolution score +25.
§
Telegram: paired user Elkratos (7620531403). Send messages via `hermes send --to telegram`
§
SECURITY RULE — κύριε Elkratos demands: ALL API keys/tokens/passwords go ONLY in profile .env, NEVER hardcoded. Use ${VAR} references in config.yaml. "na eisai prostateytiki" (be protective). This applies to every service, every time.
§
RunPod MCP verified. ComfyUI CUDA 12.8 template (cw3nka7d08) + Pony V6 XL (6.46GB uncensored). Always set PUBLIC_KEY env. Stopped pod still costs storage. Terminate to stop ALL costs. Ollama default num_ctx=32768 breaks Hermes — fix with Modelfile PARAMETER num_ctx 65536. Ref: runpod/references/ollama-num-ctx-hermes.md
§
CRITICAL SECURITY: VPS under active SSH brute force — 12,116 attempts/24h from 325 IPs. No fail2ban, no UFW, PermitRootLogin yes, PasswordAuthentication enabled (default). Top attackers: 185.242.3.195 (974), 45.156.87.254 (761). Only SSH key prevents breach. Recommend fail2ban + sshd hardening + UFW.
§
RunPod SSH RULE — πάντα SSH public key, όχι password. Κάθε pod/server deploy με PUBLIC_KEY env variable. Ο κύριος Elkratos το απαίτησε.
§
TTS voice: OpenAI Shimmer (female, warm) — κύριε Elkratos wants female voice. Set via hermes config set tts.openai.voice shimmer --profile valentina. STT: OpenAI Whisper for Greek transcription.