# SafeERC20Wrapper

A safe transfer library that tolerates tokens returning empty data.

## Properties

- Low-level `call` + `abi.decode` check: success when the call returns, with
