# Proof-of-Concept (PoC) Write-ups

Placeholder for vulnerability reproduction and exploit walk-through documents.

Expected content per PoC:

- Target contract and version (commit or tag).
- Setup: chain state, actors, balances, prerequisites.
- Attack scenario and step-by-step reproduction (prefer a runnable Foundry test in
  `test/<contract>/` that mirrors the write-up).
- Root cause, impact, and suggested fix.

Naming: `poc-<contract>-<issue>.md`, for example `poc-pull-payment-vault-reentrancy.md`.
