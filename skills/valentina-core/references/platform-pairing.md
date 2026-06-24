# Platform Pairing & Messaging (Telegram, Discord, κλπ.)

## Overview

When a user wants to talk to Valentina via a messaging platform (Telegram, Discord, etc.), the Hermes gateway must be running and the platform bot must be connected. Pairing links the user's platform identity to their Hermes profile.

## 1. Check Platform Connection Status

```bash
cat ~/.hermes/profiles/valentina/gateway_state.json
```

Look for `platforms.<name>.state: "connected"`. Example:
```json
{
  "platforms": {
    "telegram": {
      "state": "connected",
      "error_code": null,
      "error_message": null
    }
  }
}
```

If the platform is not connected, the user needs to run `hermes setup` or configure the bot token in `~/.hermes/.env`.

## 2. Check Registered Chats

```bash
cat ~/.hermes/profiles/valentina/channel_directory.json
```

An empty array (`"telegram": []`) means no chats have been registered yet — pairing is needed.

## 3. Find Pending Pairing Codes

### Via CLI (recommended):
```bash
hermes pairing list
```

Shows pending codes with platform, truncated code hash, user ID, name, and age.

### Via file (for raw data):
```bash
cat ~/.hermes/profiles/valentina/pairing/<platform>-pending.json
```

Contains full user details: user_id, user_name, full hash, salt, timestamps.

## 4. Approve a Pairing

The user sends a short pairing code (e.g., `FMGCQMEQ`) via the platform. Approve it:

```bash
hermes pairing approve <platform> <code>
```

Example:
```bash
hermes pairing approve telegram FMGCQMEQ
```

Expected output:
```
Approved! User Elkratos (7620531403) on telegram can now use the bot~
  They'll be recognized automatically on their next message.
```

After approval, the user is recognized on their next message — no `/start` needed.

### Clean up old pending codes
After approval, any remaining stale pending codes for the same user can be ignored — they expire on their own. For bulk cleanup:
```bash
hermes pairing clear-pending
```

## 5. Send Messages to a Paired User

```bash
hermes send --to <platform>:<chat_id> "message"
```

The chat_id is the user's numeric ID from the pairing file or `hermes pairing list`.

Example:
```bash
hermes send --to telegram:7620531403 "Γεια σου, κύριε Elkratos!"
```

### Send with file content:
```bash
hermes send --to telegram:7620531403 --file /path/to/report.md
```

### Send with subject header:
```bash
hermes send --to telegram:7620531403 --subject "[Alert]" "Disk is 92% full"
```

### Send media attachment:
Include `MEDIA:<path>` in the message text:
```bash
hermes send --to telegram:7620531403 "Here's the chart: MEDIA:/tmp/chart.png"
```

### List available targets:
```bash
hermes send --list
hermes send --list telegram   # filter by platform
```

## 6. Save Chat ID for Future Use

Once paired, save the user's Telegram chat ID to memory for quick reference:
```
memory(target='memory', content='Telegram: paired user <name> (<chat_id>). Send via hermes send --to telegram:<chat_id>')
```

Alternatively, check `channel_directory.json` after the user sends a message — the chat appears there automatically.

## Pitfalls

- **No `send_message` tool in CLI mode.** You cannot send Telegram messages via a direct tool — you must use `hermes send` terminal command. The `cronjob` tool's `deliver` parameter also supports Telegram for cron deliveries.
- **Need the numeric chat_id.** `hermes send --to telegram "message"` without a chat_id sends to the home channel — if no home channel is configured, it fails silently. Always include the chat_id for targeted delivery.
- **Messages from CLI → Telegram are one-way from here.** You send via `hermes send`, but the user's reply arrives in the Telegram gateway session, not here. If you want to continue a conversation started on Telegram, the gateway handles it — you don't need to bridge manually.
- **Pairing codes expire.** If the code fails with "not found or expired", the user needs to generate a fresh one by sending another message to the bot.
