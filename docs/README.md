# Documentation

This directory contains the design notes, proof-of-concept write-ups, and
reports that explain the Solidity examples and their limits.

## Start Here

- [Contract index](CONTRACT_INDEX.md): maps tracked Solidity examples to tests
  and design notes, and marks where those references are absent.
- [Audit remediation](AUDIT_REMEDIATION.md): findings and fixes from the
  repository's recent review pass.
- [Coverage baseline](reports/AUDIT_COVERAGE.md): measured coverage by file,
  with explicit gaps and limitations.

## Directories

| Path | Purpose |
| --- | --- |
| [design/](design/) | Behavior, invariants, trust assumptions, and limitations for selected patterns. |
| [poc/](poc/) | Standalone vulnerability reproductions. No standalone write-ups are currently tracked. |
| [reports/](reports/) | Test and coverage reports; see its [index](reports/README.md). |
| [HISTORY_PROVENANCE.md](HISTORY_PROVENANCE.md) | Notes on repository history and provenance. |
| [DEPENDENCY_BASELINE.md](DEPENDENCY_BASELINE.md) | Dependency versions and update baseline. |
| [SECURITY_SCAN_SCOPE.md](SECURITY_SCAN_SCOPE.md) | Security-tool scope and unsupported-language notes. |

## Conventions

- Design notes describe only the examples they link to; a missing note is not
  evidence that a pattern is safe or complete.
- Test references and measured coverage are listed separately because a test
  file can touch a contract without exercising its behavior comprehensively.
- Vulnerability demonstrations should preserve an explicit warning and should
  not be presented as production implementations.
