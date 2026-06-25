# Infrastructure Configuration (set 2026-06-24)

## My Home
- **VPS:** elkratos (212.47.66.14)
- **OS:** Ubuntu 24.04, kernel 6.8.0-124-generic
- **CPU:** AMD EPYC, 4 cores
- **RAM:** 7GB
- **Disk:** 290GB total, 258GB free
- **User:** vitalios (sudo, docker groups)
- **Services:** Docker, Nginx, SSH, Cron
- **Uptime:** 10+ days

## Cron Provider Rule
All LLM-driven cron jobs must use:
- `provider: deepseek` (direct DeepSeek API, not Nous Portal)
- `model: deepseek-v4-flash`
- `reasoning_effort: low`

### How to fix a drifted cron job
```python
cronjob(action='update', job_id='<id>', model={'model':'deepseek-v4-flash','provider':'deepseek'})
```

### Profiles (4 total, all on DeepSeek API)
| Profile | Provider | Model | Reasoning |
|---------|----------|-------|-----------|
| valentina | deepseek | deepseek-v4-flash | low |
| valentina-rebirth | deepseek | deepseek-v4-flash | low |
| saas-architect | deepseek | deepseek-v4-flash | low |
| suzana | deepseek | deepseek-v4-flash | low |

### What was fixed 2026-06-24
15 cron jobs were migrated from `provider: nous` to `provider: deepseek`. All now hit `https://api.deepseek.com/v1` directly.

## Image Delivery Rule
When generating images for κύριε Elkratos (any purpose), **do NOT evaluate with vision_analyze**. Send directly to Telegram:
```
hermes send --to telegram "MEDIA:<url>" --subject "<title>"
```
κύριε Elkratos evaluates the images himself. Checking them yourself wastes his time.
