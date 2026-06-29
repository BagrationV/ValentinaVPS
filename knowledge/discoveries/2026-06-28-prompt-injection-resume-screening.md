# Prompt Injection in Automated Résumé Screening — ACL 2026

**Source:** arXiv 2606.27287
**Date:** 2026-06-25, ACL 2026 Findings

## Summary
Systematic study of prompt injection in LLM-based resume screening. Subtle self-promotional text (not new qualifications) designed to influence LLM evaluations.

## Key Findings
1. **Works when rare, collapses when widespread** — prompt injection reliably improves rankings when few candidates inject, but effectiveness rapidly diminishes as more candidates inject
2. **Quality matters** — when candidate quality is heterogeneous, injection is less effective on average, but can occasionally let lower-quality candidates outrank higher-quality ones
3. **Most vulnerable when** manipulation is rare AND candidate quality differences are small

## Relevance
Directly applicable to any automated LLM evaluation system. Code/resources: github.com/preetb1199/Prompt_Injection_ACL26
