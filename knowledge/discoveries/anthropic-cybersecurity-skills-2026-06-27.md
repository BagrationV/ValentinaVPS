# Anthropic Cybersecurity Skills — Evaluation & Integration Plan

**Discovered:** 2026-06-27 13:35 CEST  
**Repository:** `github.com/mukul975/Anthropic-Cybersecurity-Skills`  
**Stars:** ★21,934  
**License:** Apache 2.0  
**Standard:** agentskills.io v1.1.0  
**Stats:** 817 skills · 7,257 files · 2,563 markdown files · 29 security domains

## What It Is

The largest open-source cybersecurity skills library for AI agents. Each skill follows the agentskills.io open standard — the same SKILL.md frontmatter format Hermes Agent uses. Mapped to **six industry frameworks**: MITRE ATT&CK v19.1, NIST CSF 2.0, MITRE ATLAS, MITRE D3FEND, NIST AI RMF, MITRE F3 (Fight Fraud Framework).

Hermes Agent compatibility is explicitly noted in the repo's README badge: **Hermes Agent — compatible**.

## Sample Skill Analysis

Skill sampled: `auditing-mcp-servers-for-tool-poisoning` (10KB SKILL.md)
- Frontmatter: `name`, `description`, `domain`, `subdomain`, `tags`, `version`, `author`, `license`, `nist_csf`, `mitre_attack` 
- Sections: Overview, When to Use, Prerequisites, Objectives, MITRE ATT&CK Mapping, Workflow
- Format: **Identical to Hermes Agent skill format** — plug-and-play compatible
- Quality: Production-grade, 10KB full audit workflow with commands and code blocks

## Strategic Value

1. **Direct compatibility** — SKILL.md format matches Hermes exactly. No conversion needed.
2. **Massive capability expansion** — 817 skills vs our current ~40. 20x skill count increase.
3. **Security posture** — MCP auditing, container security, cloud security, incident response, threat hunting — directly applicable to Valentina's operational security.
4. **Framework mappings** — MITRE ATT&CK + NIST CSF enable structured security posture reporting.
5. **Apache 2.0 license** — No restrictions on use, modification, or redistribution.

## Key Domains Represented

Based on directory structure analysis (817 skill directories sampled):
- AI/ML Security: prompt injection detection, LLM red-teaming, MCP/serverless auditing
- Cloud Security: AWS/GCP/Azure IAM, Kubernetes RBAC, container escape, cloud forensics
- Incident Response: ransomware response, phishing investigation, memory forensics, timeline reconstruction
- Threat Intelligence: OSINT, MISP, STIX/TAXII, threat actor profiling, dark web monitoring
- Penetration Testing: AD exploitation, network scanning, web app testing, wireless, mobile
- Compliance: NIST CSF, SOC2, PCI DSS, HIPAA, GDPR, ISO 27001
- Zero Trust: ZTNA, microsegmentation, identity-aware proxy, BeyondCorp
- OT/ICS Security: Purdue model, Modbus/DNP3, SCADA, PLC security

## Integration Approach

**Phase 1 — Selective Import (this session)**
- Clone index.json → parse all 817 skill paths
- Identify high-value skills for immediate import:
  - `auditing-mcp-servers-for-tool-poisoning` — directly protects against agent tool attacks
  - `auditing-terraform-infrastructure-for-security` — protects our deployment infrastructure
  - `securing-agentic-ai-tool-invocation` — directly applicable to our agent stack
  - `detecting-supply-chain-attacks-in-ci-cd` — protects our pipeline
  - `implementing-secrets-management-with-vault` — our .env management pattern
- Create cron job for continuous evaluation

**Phase 2 — Framework Alignment (next session)**
- Map 817 skills to our capability matrix
- Create cybersecurity sub-agent with dedicated skill set
- Propose to κύριε Elkratos

**Phase 3 — Full Integration (pending approval)**
- `git clone --depth 1` to local knowledge base
- Batch-import selected skills into Hermes profile
- Create structured security monitoring cron job

## Immediate ROI Estimate

| Action | Time | Value |
|--------|------|-------|
| Import MCP auditing skill | 5 min | Direct protection against tool poisoning |
| Create security audit cron job | 10 min | Continuous infrastructure monitoring |
| Browse skill by need | 30s/skill | Expert guidance on any security task |
| Full import | 1-2 hours | 20x skill expansion |

## Resource Impact

- Repo size: ~20MB shallow clone (7,257 files, 2,563 markdown files)
- Disk available: 41G/290G (14%) — plenty of room
- Cron job overhead: minimal (periodic git fetch + evaluation)

## Linked References

- `knowledge/pending-tasks.md` — task: "Anthropic Cybersecurity Skills — evaluate for import"
- `knowledge/curiosity/index.md` — update to mark discovery
- `knowledge/capability-matrix.md` — future: add cybersecurity skills
