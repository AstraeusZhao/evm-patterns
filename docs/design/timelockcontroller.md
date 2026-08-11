# TimelockController

A governance timelock that queues privileged calls and enforces a minimum
delay so users can react before a change takes effect.

## Functional surface

- `schedule(...)` — proposers queue a call; the operation becomes ready after
  `minDelay` seconds.
