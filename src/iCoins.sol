// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IERC20 Standard Interface
/// @notice Defines the standard functions and events for an ERC20 token
interface IERC20 {
    /// @notice Returns the total token supply
    function totalSupply() external view returns (uint256);

    /// @notice Returns the balance of a specific account
    /// @param account The address to query
    /// @return The balance of the account
    function balanceOf(address account) external view returns (uint256);

    /// @notice Transfer tokens from caller to recipient
    /// @param to The recipient address
    /// @param value The amount to transfer
    /// @return success Whether the transfer was successful
    function transfer(address to, uint256 value) external returns (bool success);

    /// @notice Returns the remaining allowance a spender has from an owner
    /// @param  owner the address of the token owner
    /// @param spender The address of the spender
    /// @return The remaining allowance
    function allowance(address owner, address spender) external view returns (uint256);

    /// @notice Approves a spender to use a specified amount of tokens
    /// @param spender The address allowed to spend
    /// @param value The amount allowed
    /// @return success Whether the approval was successful
    function approve(address spender, uint256 value) external returns (bool success);

    /// @notice Transfers tokens on behalf of an owner (if approved)
    /// @param from The address to transfer tokens from
    /// @param to The recipient address
    /// @param value The amount to transfer
    /// @return success Whether the transfer was successful
    function transferFrom(address from, address to, uint256 value) external returns (bool success);

    /// @notice Emitted when tokens are transferred
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Emitted when approval is given
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
