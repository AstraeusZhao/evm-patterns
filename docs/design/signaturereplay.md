# SignatureReplay

EIP-712 signed claims protected against replay by per-account nonces.

## Properties

- Digests are domain-separated and typed-data hashed.
- `ecrecover` recovers the signer; the recovered account must match the
  configured signer.
- Each successful claim increments the account nonce, invalidating old
  signatures.
- Deadline checks bound the lifetime of a signature.

## Trust assumptions

- The signer key must be held off-chain; a leaked key lets anyone claim on
  behalf of accounts.
