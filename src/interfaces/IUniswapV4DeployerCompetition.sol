// SPADIX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

/// @title UniswapV4DeployerCompetition
/// @notice A competition to deploy the UniswapV4 contract with the best address
interface IUniswapV4DeployerCompetition {
    event NewAddressFound(address indexed bestAddress, address indexed minter, uint256 score);

    error InvalidBytecode();
    error CompetitionNotOver(uint256 currentTime, uint256 deadline);
    error CompetitionOver(uint256 currentTime, uint256 deadline);
    error NotAllowedToDeploy(address sender, address bestAddressSender);
    error BountyTransferFailed();
    error WorseAddress(address newAddress, address bestAddress, uint256 newScore, uint256 bestScore);
    error InvalidTokenId(uint256 tokenId);

    /// @notice Updates the best address if the new address has a better vanity score
    /// @param salt The salt to use to compute the new address with CREATE2
    function updateBestAddress(bytes32 salt) external;

    /// @notice Allows the winner to deploy the Uniswap v4 PoolManager contract
    /// @param bytecode The bytecode of the Uniswap v4 PoolManager contract
    /// @dev The bytecode must match the initCodeHash
    function deploy(bytes memory bytecode) external;
}
