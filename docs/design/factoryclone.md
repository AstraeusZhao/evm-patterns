# FactoryClone

A factory that deploys EIP-1167 minimal proxy clones via CREATE2.

## Properties

- Runtime bytecode is the canonical 45-byte minimal proxy.
- Clone addresses are deterministic per salt.
- The implementation is immutable and shared by all clones.
