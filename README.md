# EVM Patterns

EVM Patterns is a learning and review repository for Solidity contracts on the
EVM. It contains small implementations of common patterns alongside examples
of mistakes and attack surfaces. The examples are not a production framework.

## Start

Install [Foundry](https://book.getfoundry.sh/) and run these commands from the
repository root:

```bash
forge build
forge test
forge fmt --check
```

## Browse

- [Web contract browser](web/README.md): a React interface with a Rust API for
  browsing Solidity source files, themes, and design notes.
- [Contract index](docs/CONTRACT_INDEX.md): source files, available tests, and
  design notes for each example.
- [Design notes](docs/design/): behavior, assumptions, and limitations for
  selected patterns.
- [Coverage baseline](docs/reports/AUDIT_COVERAGE.md): measured per-file
  coverage and its limits.
- [Audit remediation notes](docs/AUDIT_REMEDIATION.md): findings and changes
  from the recent review pass.
- [Security policy](SECURITY.md) and [changelog](CHANGELOG.md).

## Repository map

| Path | Contents |
| --- | --- |
| `src/` | Solidity examples, one directory per pattern or contract family. |
| `test/` | Focused Foundry suites and cross-cutting regression tests. Coverage varies by example. |
| `docs/design/` | Design and trust-boundary notes for selected examples. |
| `docs/poc/` | Standalone vulnerability reproductions; see its index for current status. |
| `docs/reports/` | Test and coverage reports. |
| `script/` | Local deployment and demonstration scripts. |
| `web/` | PNPM/Vite frontend and Rust API for browsing local contract sources and notes. |

## Scope

Some contracts intentionally demonstrate unsafe techniques, including weak
randomness, `tx.origin` authorization, and unchecked low-level calls. Their
warnings are part of the example. None of the contracts has been independently
audited as a production system. Do not deploy an example to custody real assets
without a separate design review, audit, and deployment process.

Test coverage is uneven: some examples have dedicated suites, some are touched
by `test/AuditRegression.t.sol`, and some have no behavioral tests yet. A
passing test suite is not a security certification. The [contract index](docs/CONTRACT_INDEX.md)
and [coverage report](docs/reports/AUDIT_COVERAGE.md) show the current evidence.

## Adding an example

Add or update the source, focused tests, and a design note describing behavior,
trust assumptions, and limitations. Then update the [contract index](docs/CONTRACT_INDEX.md)
and [changelog](CHANGELOG.md).

## License

AGPL-3.0. See [LICENSE](LICENSE).
