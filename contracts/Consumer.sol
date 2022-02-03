//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import "./lib/VRF.sol";

interface IKenshi {
    function approveAndCall(
        address spender,
        uint256 value,
        bytes memory data
    ) external returns (bool);
}

abstract contract Consumer {
    /* Request tracking */
    mapping(uint256 => bool) _requests;
    uint256 private _requestId;

    /* Kenshi related */
    uint256 private _approve;
    address private _kenshiAddr;
    address private _coordinatorAddr;

    /* VRF options */
    bool private _shouldVerify;
    uint256[2] private _publicKey;

    constructor() {
        _approve = (1e13 * 1e18) / 1e2;
    }

    /**
     * @dev Sets the public key used for VRF verification.
     */
    function setPublicKey(bytes memory publicKey) internal {
        _publicKey = VRF.decodePoint(publicKey);
    }

    /**
     * @dev Get the public key used for VRF verification.
     */
    function getPublicKey() internal view returns (bytes memory) {
        return VRF.encodePoint(_publicKey[0], _publicKey[1]);
    }

    /**
     * @dev Sets if the received random number should be verified.
     */
    function setShouldVerify(bool shouldVerify) internal {
        _shouldVerify = shouldVerify;
    }

    /**
     * @dev Sets the Kenshi VRF coordinator address.
     */
    function setCoordinatorAddr(address coordinatorAddr) internal {
        _coordinatorAddr = coordinatorAddr;
    }

    /**
     * @dev Sets the Kenshi token address.
     */
    function setKenshiAddr(address kenshiAddr) internal {
        _kenshiAddr = kenshiAddr;
    }

    /**
     * @dev Request a random number.
     *
     * @return {requestId} Use to map received random numbers to requests.
     */
    function requestRandomness() internal returns (uint256) {
        uint256 currentId = _requestId++;
        IKenshi(_kenshiAddr).approveAndCall(
            _coordinatorAddr,
            _approve,
            abi.encode(_publicKey, currentId)
        );
        return currentId;
    }

    event RandomnessFulfilled(
        uint256 requestId,
        uint256 randomness,
        uint256[4] _proof,
        bytes _message
    );

    /**
     * @dev Called by the VRF Coordinator.
     */
    function onRandomnessReady(
        uint256[4] memory _proof,
        bytes memory _message,
        uint256[2] memory _uPoint,
        uint256[4] memory _vComponents,
        uint256 requestId
    ) external {
        require(
            msg.sender == _coordinatorAddr,
            "Consumer: Only Coordinator can fulfill"
        );
        if (_shouldVerify) {
            bool isValid = fastVerify(_proof, _message, _uPoint, _vComponents);
            require(isValid, "Consumer: Proof not valid");
        }
        bytes32 beta = gammaToHash(_proof[0], _proof[1]);
        uint256 randomness = uint256(beta);
        emit RandomnessFulfilled(requestId, randomness, _proof, _message);
        fulfillRandomness(requestId, randomness);
    }

    /**
     * @dev You need to override this function in your smart contract.
     */
    function fulfillRandomness(uint256 requestId, uint256 randomness)
        internal
        virtual;

    /* VRF functions */

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
        uint256[4] memory _proof,
        bytes memory _message
    ) public view returns (uint256[2] memory, uint256[4] memory) {
        return VRF.computeFastVerifyParams(_publicKey, _proof, _message);
    }

    function verify(uint256[4] memory _proof, bytes memory _message)
        public
        view
        returns (bool)
    {
        return VRF.verify(_publicKey, _proof, _message);
    }

    function fastVerify(
        uint256[4] memory _proof,
        bytes memory _message,
        uint256[2] memory _uPoint,
        uint256[4] memory _vComponents
    ) public view returns (bool) {
        return
            VRF.fastVerify(_publicKey, _proof, _message, _uPoint, _vComponents);
    }

    function gammaToHash(uint256 _gammaX, uint256 _gammaY)
        public
        pure
        returns (bytes32)
    {
        return VRF.gammaToHash(_gammaX, _gammaY);
    }
}
