# TimelockController

A governance timelock that queues privileged calls and enforces a minimum
delay so users can react before a change takes effect.

## Functional surface

- `schedule(...)` — proposers queue a call; the operation becomes ready after
  `minDelay` seconds.
- `execute(...)` — executors run ready operations within the grace window.
- `cancel(...)` — proposers remove an operation before it becomes ready.
- `grantRole` / `revokeRole` / `updateDelay` — the admin manages roles and the
  minimum delay (capped at 30 days).

## State machine

An operation id is in exactly one of four states:

| State | Condition |
| --- | --- |
| `Unset` | never scheduled, or deleted after execution/cancellation |
| `Waiting` | `timestamp` in the future |
| `Ready` | now in `[timestamp, timestamp + GRACE_PERIOD]` |
| `Expired` | now past `timestamp + GRACE_PERIOD` |

A `predecessor` is accepted only if it is `Unset` (never set or already done),
which builds dependency chains between operations.

## Security properties

- **Role separation** — proposers cannot execute and executors cannot schedule.
- **Grace period** — operations expire after 14 days instead of staying ready
  forever.
- **Predecessor checks** — ordering dependencies are enforced on both schedule
  and execute paths.

## Trust assumptions

- The admin can grant roles and shorten the delay; it must itself be
