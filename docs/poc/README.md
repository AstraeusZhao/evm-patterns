# Proof-of-Concept (PoC) Write-ups

No standalone PoC write-ups are currently tracked in this directory. Some
contracts under [src/](../../src/) are intentionally vulnerable demonstrations;
their scope and warnings are described in the
[contract index](../CONTRACT_INDEX.md).

Expected content per PoC:

- Target contract and version (commit or tag).
- Setup: chain state, actors, balances, prerequisites.
- Attack scenario and step-by-step reproduction (prefer a runnable Foundry test in
  `test/<contract>/` that mirrors the write-up).
- Root cause, impact, and suggested fix.

Naming: `poc-<contract>-<issue>.md`, for example
`poc-pull-payment-vault-reentrancy.md`.
