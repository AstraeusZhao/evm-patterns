# SignatureReplay

EIP-712 signed claims protected against replay by per-account nonces.

## Properties

- Digests are domain-separated and typed-data hashed.
- `ecrecover` recovers the signer; the recovered account must match the
  configured signer.
