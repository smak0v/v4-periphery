// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";

/**
 * @dev PackedPositionInfo is a packed version of solidity structure.
 * Using the packaged version saves gas and memory by not storing the structure fields in memory slots.
 *
 * Layout:
 * 200 bits poolId | 24 bits tickUpper | 24 bits tickLower | 8 bits hasSubscriber
 *
 * Fields in the direction from the least significant bit:
 *
 * A flag to know if the tokenId is subscribed to an address
 * uint8 hasSubscriber;
 *
 * The tickUpper of the position
 * int24 tickUpper;
 *
 * The tickLower of the position
 * int24 tickLower;
 *
 * The truncated poolId
 * bytes25 poolId;
 *
 * Note: If more bits are needed, hasSubscriber can be a single bit.
 *
 */
type PackedPositionInfo is uint256;

library PositionInfoLibrary {
    using PoolIdLibrary for PoolKey;

    PackedPositionInfo internal constant EMPTY_POSITION_INFO = PackedPositionInfo.wrap(0);

    uint256 internal constant MASK_UPPER_200_BITS = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000;
    uint256 internal constant MASK_8_BITS = 0xFF;
    uint24 internal constant MASK_24_BITS = 0xFFFFFF;
    uint256 internal constant SET_SUBSCRIBE = 0x01;
    uint8 internal constant TICK_LOWER_OFFSET = 8;
    uint8 internal constant TICK_UPPER_OFFSET = 32;

    function poolId(PackedPositionInfo info) internal pure returns (bytes25 _poolId) {
        assembly ("memory-safe") {
            _poolId := and(MASK_UPPER_200_BITS, info)
        }
    }

    function tickLower(PackedPositionInfo info) internal pure returns (int24 _tickLower) {
        assembly ("memory-safe") {
            _tickLower := signextend(2, shr(TICK_LOWER_OFFSET, info))
        }
    }

    function tickUpper(PackedPositionInfo info) internal pure returns (int24 _tickUpper) {
        assembly ("memory-safe") {
            _tickUpper := signextend(2, shr(TICK_UPPER_OFFSET, info))
        }
    }

    function hasSubscriber(PackedPositionInfo info) internal pure returns (bool _hasSubscriber) {
        assembly ("memory-safe") {
            _hasSubscriber := and(MASK_8_BITS, info)
        }
    }

    /// @dev this does not actually set any storage
    function setSubscribe(PackedPositionInfo info) internal pure returns (PackedPositionInfo _info) {
        assembly ("memory-safe") {
            _info := or(info, SET_SUBSCRIBE)
        }
    }

    /// @dev this does not actually set any storage
    function setUnsubscribe(PackedPositionInfo info) internal pure returns (PackedPositionInfo _info) {
        assembly ("memory-safe") {
            _info := and(info, not(SET_SUBSCRIBE))
        }
    }

    /// @notice Creates the default PositionInfo struct
    /// @dev Called when minting a new position
    /// @param _poolKey the pool key of the position
    /// @param _tickLower the lower tick of the position
    /// @param _tickUpper the upper tick of the position
    /// @return info packed position info, with the truncated poolId and the hasSubscriber flag set to false
    function initialize(PoolKey memory _poolKey, int24 _tickLower, int24 _tickUpper)
        internal
        pure
        returns (PackedPositionInfo info)
    {
        bytes25 _poolId = bytes25(PoolId.unwrap(_poolKey.toId()));
        assembly {
            info :=
                or(
                    or(and(MASK_UPPER_200_BITS, _poolId), shl(TICK_UPPER_OFFSET, and(MASK_24_BITS, _tickUpper))),
                    shl(TICK_LOWER_OFFSET, and(MASK_24_BITS, _tickLower))
                )
        }
    }
}
