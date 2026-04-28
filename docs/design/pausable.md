# Pausable

An owner-controlled pause switch used to stop state-changing operations during
incidents.

## Properties

- `pause` and `unpause` are owner-only and idempotent-guarded.
- `whenNotPaused` / `whenPaused` modifiers gate downstream functions.

## Trust assumptions

- Pausing is an operational stop, not a recovery path; funds must be
  recoverable through other mechanisms when the contract is paused.
