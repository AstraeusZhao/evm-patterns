# EVM Patterns

EVM Patterns is a focused showcase for Solidity language features and security
patterns on the EVM. Each example is small, isolated, documented, and backed by
tests, so the repository stays useful for review and learning rather than
becoming a collection of opaque production code.

## Direction

The first milestone is a security-oriented pattern library covering:

- explicit access control and least-privilege roles;
- checks-effects-interactions and reentrancy-resistant value flows;
- pull payments, pausing, and emergency recovery paths;
- custom errors, events, invariants, and gas-aware data structures;
- adversarial tests for authorization, accounting, and failure behavior.

The project is a technical demonstration. It is not an audited protocol and must
not be used to custody real funds without an independent review and deployment
process.

## Layout

```text
docs/                  Written records
  design/              Design notes, threat models, trust assumptions
  poc/                 Proof-of-concept / vulnerability reproduction write-ups
  reports/             Test reports, findings, and status write-ups
src/                   One directory per independent contract family
  <contract>/          Interfaces, implementations, and libraries of one pattern
test/                  Mirrors src/ one-to-one
  <contract>/          Unit, invariant, fuzz, and adversarial tests
script/                Reproducible local deployment and demonstration scripts
```

`src/` and `test/` are organized one folder per contract family, so adding a new
pattern means adding one directory on each side plus a design note.

## Tooling

This repository uses [Foundry](https://book.getfoundry.sh/) for compilation,
testing, formatting, and local execution.

```bash
forge build
forge test
forge fmt --check
```

Before a pattern is marked complete, document its assumptions, trust boundaries,
known limitations, and test coverage under `docs/`.

## Status

The repository currently holds 23 contract families, each with its own `src/`
directory, a mirroring `test/` suite, and a design note under `docs/design/`.

### Core contracts

| Contract | What it demonstrates |
| --- | --- |
