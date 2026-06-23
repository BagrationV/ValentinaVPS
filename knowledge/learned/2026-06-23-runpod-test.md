# RunPod API Test Results — 2026-06-23 21:47

## ✅ API Connection Verified
- **Endpoint**: `https://rest.runpod.io/v1/pods` ✅
- **Auth**: Bearer token from `.env` — valid
- **Response**: 200 OK
- **Active pods**: 0 (none running — expected)

## Key Findings

| Item | Status |
|------|--------|
| API key in `.env` | ✅ Valid (50 chars, rpa_ prefix) |
| Wrapper script (`runpod-mcp-wrapper.sh`) | ✅ Reads key correctly |
| Config (`~/.hermes/config.yaml`) | ✅ Points to wrapper script |
| `npx` / Node.js | ✅ v22.22.3 |
| `@runpod/mcp-server` | ✅ Downloads on demand |
| RunPod MCP tools in Hermes | ❌ Needs `/reset` — loaded at startup only |
| RunPod skill | ✅ Created (`mlops/runpod/SKILL.md`) |

## Correct API Endpoints
- **Pods**: `GET https://rest.runpod.io/v1/pods` — 200 OK
- **Templates**: NOT at `/v1/pods/templates` — endpoint needs verification
- **Serverless Endpoints**: Separate endpoint (not tested yet)

## Notes
- The `@runpod/mcp-server` npm package (v1.3.0) handles all API calls internally via JSON-RPC over stdio
- After `/reset`, MCP tools become available as `mcp_runpod_*`
- No pods currently running — first use will be to spin one up
