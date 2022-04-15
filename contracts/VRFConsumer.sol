//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

interface IKenshi {
    function approveAndCall(
        address spender,
        uint256 value,
        bytes memory data
    ) external returns (bool);
}

interface IVRFUtils {
    function fastVerify(
        uint256[4] memory proof,
        bytes memory message,
        uint256[2] memory uPoint,
        uint256[4] memory vComponents
    ) external view returns (bool);

    function gammaToHash(uint256 _gammaX, uint256 _gammaY)
        external
        pure
        returns (bytes32);
}

interface ICoordinator {
    function getKenshiAddr() external view returns (address);

    function getVrfUtilsAddr() external view returns (address);
}

abstract contract VRFConsumer {
    /* Request tracking */
    mapping(uint256 => bool) _requests;
    uint256 private _requestId;

    /* Kenshi related */
    uint256 private _approve;

    IKenshi private _kenshi;
    IVRFUtils private _utils;
    ICoordinator private _coordinator;

    /* VRF options */
    bool private _shouldVerify;
    bool private _silent;

    constructor() {
        _approve = (1e13 * 1e18) / 1e2;
    }

    /**
     * @dev Setup various VRF related settings:
     * - Coordinator Address: Kenshi VRF coordinator address
     * - Should Verify: Set if the received randomness should be verified
     * - Silent: Set if an event should be emitted on randomness delivery
     */
    function setupVRF(
        address coordinatorAddr,
        bool shouldVerify,
        bool silent
    ) internal {
        _coordinator = ICoordinator(coordinatorAddr);

        address _vrfUtilsAddr = _coordinator.getVrfUtilsAddr();
        address _kenshiAddr = _coordinator.getKenshiAddr();

        _utils = IVRFUtils(_vrfUtilsAddr);
        _kenshi = IKenshi(_kenshiAddr);

        _shouldVerify = shouldVerify;
        _silent = silent;
    }

    /**
     * @dev Setup VRF, short version.
     */
    function setupVRF(address coordinatorAddr) internal {
        setupVRF(coordinatorAddr, false, false);
    }

    /**
     * @dev Sets the Kenshi VRF coordinator address.
     */
    function setVRFCoordinatorAddr(address coordinatorAddr) internal {
        _coordinator = ICoordinator(coordinatorAddr);
    }

    /**
     * @dev Sets the Kenshi VRF verifier address.
     */
    function setVRFUtilsAddr(address vrfUtilsAddr) internal {
        _utils = IVRFUtils(vrfUtilsAddr);
    }

    /**
     * @dev Sets the Kenshi token address.
     */
    function setVRFKenshiAddr(address kenshiAddr) internal {
        _kenshi = IKenshi(kenshiAddr);
    }

    /**
     * @dev Sets if the received random number should be verified.
     */
    function setVRFShouldVerify(bool shouldVerify) internal {
        _shouldVerify = shouldVerify;
    }

    /**
     * @dev Sets if should emit an event once the randomness is fulfilled.
     */
    function setVRFIsSilent(bool silent) internal {
        _silent = silent;
    }

    /**
     * @dev Request a random number.
     *
     * @return {requestId} Use to map received random numbers to requests.
     */
    function requestRandomness() internal returns (uint256) {
        uint256 currentId = _requestId++;
        _kenshi.approveAndCall(
            address(_coordinator),
            _approve,
            abi.encode(currentId)
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
        uint256[4] memory proof,
        bytes memory message,
        uint256[2] memory uPoint,
        uint256[4] memory vComponents,
        uint256 requestId
    ) external {
        require(
            msg.sender == address(_coordinator),
            "Consumer: Only Coordinator can fulfill"
        );

        if (_shouldVerify) {
            bool isValid = _utils.fastVerify(
                proof,
                message,
                uPoint,
                vComponents
            );
            require(isValid, "Consumer: Proof not valid");
        }

        bytes32 beta = _utils.gammaToHash(proof[0], proof[1]);
        uint256 randomness = uint256(beta);

        if (!_silent) {
            emit RandomnessFulfilled(requestId, randomness, proof, message);
        }

        fulfillRandomness(requestId, randomness);
    }

    /**
     * @dev You need to override this function in your smart contract.
     */
    function fulfillRandomness(uint256 requestId, uint256 randomness)
        internal
        virtual;
}
