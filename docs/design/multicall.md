# Multicall

A batching utility that executes several self-calls in one transaction.

## Properties

- Uses `delegatecall` to preserve `msg.sender` and storage context.
- Failures revert the entire batch atomically.

## Trust assumptions

- The multicall target must be trusted: delegatecall semantics mean the called
