// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "./lib/VRF.sol";

/**
 * @title Test Helper for the VRF contract
 * @dev The aim of this contract is twofold:
 * 1. Raise the visibility modifier of VRF contract functions for testing purposes
 * 2. Removal of the `pure` modifier to allow gas consumption analysis
 * @author Witnet Foundation
 */
contract VRFUtils {
    address private _owner;
    uint256[2] private _publicKey;

    constructor() {
        _owner = msg.sender;
    }

    /**
     * @dev Sets the public key used for VRF verification.
     */
    function setPublicKey(bytes memory publicKey) public {
        require(msg.sender == _owner, "Only owner");
        _publicKey = VRF.decodePoint(publicKey);
    }

    /**
     * @dev Get the public key used for VRF verification.
     */
    function getPublicKey() public view returns (bytes memory) {
        return VRF.encodePoint(_publicKey[0], _publicKey[1]);
    }

    function decodeProof(bytes memory _proof)
        public
        pure
        returns (uint256[4] memory)
    {
        return VRF.decodeProof(_proof);
    }

    function decodePoint(bytes memory _point)
        public
        pure
        returns (uint256[2] memory)
    {
        return VRF.decodePoint(_point);
    }

    function computeFastVerifyParams(
        uint256[2] memory publicKey,
        uint256[4] memory proof,
        bytes memory message
    ) public pure returns (uint256[2] memory, uint256[4] memory) {
        return VRF.computeFastVerifyParams(publicKey, proof, message);
    }

    function computeFastVerifyParams(
        uint256[4] memory proof,
        bytes memory message
    ) public view returns (uint256[2] memory, uint256[4] memory) {
        return VRF.computeFastVerifyParams(_publicKey, proof, message);
    }

    function verify(
        uint256[2] memory publicKey,
        uint256[4] memory proof,
        bytes memory message
    ) public pure returns (bool) {
        return VRF.verify(publicKey, proof, message);
    }

    function verify(uint256[4] memory proof, bytes memory message)
        public
        view
        returns (bool)
    {
        return VRF.verify(_publicKey, proof, message);
    }

    function fastVerify(
        uint256[2] memory publicKey,
        uint256[4] memory proof,
        bytes memory message,
        uint256[2] memory uPoint,
        uint256[4] memory vComponents
    ) public pure returns (bool) {
        return VRF.fastVerify(publicKey, proof, message, uPoint, vComponents);
    }

    function fastVerify(
        uint256[4] memory proof,
        bytes memory message,
        uint256[2] memory uPoint,
        uint256[4] memory vComponents
    ) public view returns (bool) {
        return VRF.fastVerify(_publicKey, proof, message, uPoint, vComponents);
    }

    function gammaToHash(uint256 _gammaX, uint256 _gammaY)
        public
        pure
        returns (bytes32)
    {
        return VRF.gammaToHash(_gammaX, _gammaY);
    }
}
