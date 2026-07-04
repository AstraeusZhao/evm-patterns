# SafeERC20Wrapper

A safe transfer library that tolerates tokens returning empty data.

## Properties

- Low-level `call` + `abi.decode` check: success when the call returns, with
  an optional boolean that must be `true`.
- Works with USDT-style tokens that return nothing.

