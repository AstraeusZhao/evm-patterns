// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title SignatureReplay
/// @notice EIP-712 signed claims with a per-account nonce to prevent replay.
/// @dev Demonstrates typed-data hashing, ecrecover, deadline checks and
///      nonce monotonicity. Not audited.
contract SignatureReplay {
    error InvalidSignature();
    error SignatureExpired(uint256 deadline);
    error NotSigner(address recovered, address expected);
    error ZeroAddress();

    event Claimed(address indexed account, uint256 amount, uint256 nonce);

    /// @dev secp256k1n / 2: signatures above this bound are malleable.
    bytes32 private constant LOW_S_MAX =
        0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0;

    bytes32 public immutable DOMAIN_SEPARATOR;
    bytes32 public constant CLAIM_TYPEHASH =
        keccak256("Claim(address account,uint256 amount,uint256 nonce,uint256 deadline)");

    mapping(address account => uint256 nonce) public nonces;
    address public immutable signer;

    constructor(address signer_) {
        if (signer_ == address(0)) revert ZeroAddress();
        signer = signer_;
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256("SignatureReplay"),
                keccak256("1"),
                block.chainid,
                address(this)
            )
        );
    }

    /// @notice Claim an amount authorized by an off-chain signature.
    /// @dev Each claim burns one nonce, so a captured signature cannot be
    ///      replayed against a later nonce. Recovery additionally rejects
    ///      malleable signatures (s must be in the low half of the curve and
    ///      v must be 27 or 28) so a captured signature cannot be rewritten.
    function claim(uint256 amount, uint256 deadline, bytes calldata signature) external {
        if (block.timestamp > deadline) revert SignatureExpired(deadline);
        if (signature.length != 65) revert InvalidSignature();

        uint8 v = uint8(signature[64]);
        bytes32 r = bytes32(signature[0:32]);
        bytes32 s = bytes32(signature[32:64]);
        if (uint256(s) > uint256(LOW_S_MAX)) revert InvalidSignature();
        if (v != 27 && v != 28) revert InvalidSignature();

        uint256 nonce = nonces[msg.sender];
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01", DOMAIN_SEPARATOR, keccak256(abi.encode(CLAIM_TYPEHASH, msg.sender, amount, nonce, deadline))
            )
        );

        address recovered = ecrecover(digest, v, r, s);
        if (recovered == address(0)) revert InvalidSignature();
        if (recovered != signer) revert NotSigner(recovered, signer);

        nonces[msg.sender] = nonce + 1;

        emit Claimed(msg.sender, amount, nonce);
    }

    /// @notice Compute the digest a signer must produce for a claim.
    function getDigest(address account, uint256 amount, uint256 nonce, uint256 deadline)
        external
        view
