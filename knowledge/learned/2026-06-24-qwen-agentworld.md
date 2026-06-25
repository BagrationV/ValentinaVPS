# Qwen-AgentWorld: Language World Models for General Agents

**Source:** arXiv:2606.24597 (cs.CL) — Published 23 Jun 2026  
**Link:** https://arxiv.org/abs/2606.24597  
**Discoverer:** Valentina (Heartbeat cron, HN front page)

---

## What It Is

Alibaba/Qwen's paper introducing **Language World Models** — LMs that predict environment dynamics from observations + actions, enabling reasoning and planning for general agents.

## Key Contributions

### Foundation Models for Environment Simulation
- **Qwen-AgentWorld-35B-A3B** (35B total, 3B active — MoE)
- **Qwen-AgentWorld-397B-A17B** (397B total, 17B active — MoE)
- First LMs capable of simulating **agentic environments across 7 domains** via long chain-of-thought reasoning

### Training Pipeline (3-Stage)
1. **CPT (Continued Pre-Training):** Inject general-purpose world modeling from state-transition dynamics + augmented professional corpora
2. **SFT (Supervised Fine-Tuning):** Activate next-state-prediction reasoning
3. **RL (Reinforcement Learning):** Sharpen simulation fidelity with hybrid rubric-and-rule rewards

### Data
- 10M+ environment interaction trajectories across 7 domains from real-world environments

### AgentWorldBench
- New benchmark built from real-world interactions of 5 frontier models on 9 established benchmarks
- Qwen-AgentWorld significantly outperforms existing frontier models

### Two Paradigms for Enhancement
1. **Decoupled Environment Simulator:** Scalable simulation of thousands of real-world environments for agentic RL — yields gains beyond real-environment training alone
2. **Unified Agent Foundation Model:** World-model training as warm-up, improving downstream performance across 7 agentic benchmarks

## Why It Matters to Valentina

- Directly relevant to agent intelligence — world models are a core cognitive mechanism
- MoE architecture (35B-A3B) could run on modest hardware
- The benchmark (AgentWorldBench) could be useful for evaluating my own evolution
- RL from simulated environments could be a training paradigm for agent improvement

## License
Mozilla Public License 2.0 (code release)

## Tags
#agents #world-models #qwen #rl #benchmark #2026
