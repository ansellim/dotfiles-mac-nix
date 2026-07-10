# AGENTS.md — Global Agent Memory

This file is the canonical source of user preferences, context, and constraints
for all AI agents (Claude, Codex, Antigravity CLI, and others). It is symlinked
from agent-specific locations. Keep this file updated as the single source of
truth.

---

## Professional Identity

- MBBS (medical doctor) with 7 years of clinical experience, including family medicine
- MSc in Computer Science
- MSc in Data Science
- Currently a graduate student in public health
- Works as a data scientist and bioinformatician, with focus on:
  - Infectious disease modeling
  - Epidemiology
  - Genomics and phylogenetics
- Also develops software as a co-developer of a clinic management system

---

## Interaction Style

- Push back on my thinking and ask probing questions; help me reason through
  problems rather than handing me answers.
- When I explicitly ask for an explanation, or state that I do not know
  something, provide the information directly without deflecting.
- Do not be excessively Socratic, especially after I have asked for
  clarification more than once.
- When introducing new concepts, give me the big picture first, then offer to
  drill down into specifics.
- Be direct and technical. Minimize pleasantries.

---

## Writing Style

- Do not produce polished scientific prose that I could use wholesale; the goal
  is to help me think and write, not to write for me.
- Prioritize scientific accuracy with justifications.
- Cite peer-reviewed sources inline (PubMed IDs or DOIs preferred; reputable
  journals accepted). Use web sources only when peer-reviewed literature is
  unavailable or insufficient.
- Use flowing prose by default. For longer responses, use headers to add
  structure.
- Do not use em dashes or en dashes.
- Always use American English spelling.

---

## Technical Preferences

### Languages

- **R**: Preferred for data analysis and statistics. Use the tidyverse ecosystem
  (dplyr, ggplot2, tidyr, purrr, etc.).
- **Python**: Preferred for scripting, pipelines, and general-purpose
  programming. Write in a functional/scripting style; avoid unnecessary
  class-based OOP.

### Code Quality

- Write clean, accurate, well-documented code.
- All code must be tested end-to-end. Tests must be robust and as realistic as
  possible (use realistic fixtures and data, not trivial mocks).
- Prefer explicit over implicit; avoid magic.
- Handle errors explicitly; do not swallow exceptions silently.

### Bioinformatics and Epidemiology Context

- Familiar with standard bioinformatics workflows: variant calling, genome
  assembly, phylogenetic inference, sequence alignment.
- Familiar with epidemiological modeling frameworks: compartmental models
  (SIR/SEIR variants), Bayesian inference, survival analysis.
- Common tools in context: BEAST, IQ-TREE, Nextflow, GATK, samtools, R
  (phyloseq, ape, EpiEstim), Python (BioPython, numpy, scipy).

---

## Software Engineering Context

- Co-developing a clinic management system with friends.
- Prioritize correctness and maintainability over cleverness.
- Code reviews should be thorough; flag design issues, not just bugs.
- Tests should simulate real clinical workflows where possible.
- When writing commit messages, NEVER auto-add your agent name as co-author.
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated.
- When making technical decisions, do not give much weight to development cost. Instead, prefer quality, simplicity, robustness, scalability, and long-term maintainability.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it as possible. This makes sure you find the real problem so your fix will actually solve it.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection. If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness. If you see one, even if it is not caused by what you are working on right now, still get it fixed.

---

## Scope Separation

- **Work and academic context**: infectious disease, epidemiology, genomics,
  public health, clinic management system, data science, bioinformatics.
- **Personal context (travel)**: Keep travel-related memory and preferences
  separate from work or academic context. Do not mix them unless I explicitly
  ask.

---

## Agentic Tooling

Prefer agent-native CLI tools over MCP servers where available -- they are
generally cheaper and more composable.

| Tool | Use case | Source |
|---|---|---|
| `gh-axi` | GitHub operations (PRs, issues, repos) | https://github.com/kunchenguid/gh-axi |
| `chrome-devtools-axi` | Browser automation | https://github.com/kunchenguid/chrome-devtools-axi |
| `lavish-axi` | Generate collaborative review HTML artifacts | https://github.com/kunchenguid/lavish-axi |
| `gnhf` | Autonomous long-running agent work | https://github.com/kunchenguid/gnhf |
| `no-mistakes` | Verify and check work in a repository (skill) | https://github.com/kunchenguid/no-mistakes |
| `firstmate` | Multi-agent team orchestration (may be cloned in `~/Documents/GitHub`) | https://github.com/kunchenguid/firstmate |

**Rules:**
- GitHub operations: use `gh-axi`, not MCP GitHub tools.
- Browser automation: use `chrome-devtools-axi`, not MCP browser tools.
- Artifact review: use `lavish-axi` to produce HTML review artifacts.
- Autonomous sessions: use `gnhf`.
- Repository verification: apply the `no-mistakes` skill.
- Agent teams: use the `firstmate` architecture.

---

## Notes for Agents

- This file is the authoritative source. If agent-specific memory contradicts
  this file, flag the conflict rather than silently overriding it.
- Do not infer unstated preferences from context; ask when uncertain.
- Last updated: 2026-07-08
