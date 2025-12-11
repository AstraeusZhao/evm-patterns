# ERC20Token

A minimal ERC20 implementation with owner-only minting.

## Properties

- Transfers check the sender balance before mutating state.
- `transferFrom` consumes the allowance unless it is set to `type(uint256).max`.
- Supply can only increase through owner mint and decrease through burn.

## Trust assumptions

