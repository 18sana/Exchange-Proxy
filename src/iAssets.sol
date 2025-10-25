// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title ERC721 Standard Interface
/// @notice This interface follows the ERC721 Non-Fungible Token Standard
/// @dev Defines the essential functions and events required for ERC721 contracts
interface IERC721 {
    /// @dev Emitted when ownership of any NFT changes by any mechanism
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /// @dev Emitted when the approved address for an NFT is changed 
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /// @dev Emitted when an operator is enabled or disabled for an owner
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /// @notice Count all NFTs assigned to an owner
    /// @param owner Address for which balance is queried
    /// @return balance Number of NFTs owned by `owner`
    function balanceOf(address owner) external view returns (uint256 balance);

    /// @notice Find the owner of an NFT
    /// @param tokenId The identifier for an NFT
    /// @return owner Address currently marked as the owner of the given NFT
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /// @notice Transfers the ownership of an NFT from one address to another
    /// @param from The current owner of the NFT
    /// @param to The new owner
    /// @param tokenId The NFT to transfer
    function transferFrom(address from, address to, uint256 tokenId) external;

    /// @notice Safely transfers the ownership of an NFT from one address to another
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /// @notice Safely transfers the ownership of an NFT from one address to another with additional data
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /// @notice Change the approved address for an NFT
    /// @param to The address to be approved
    /// @param tokenId The NFT to approve
    function approve(address to, uint256 tokenId) external;

    /// @notice Get the approved address for a single NFT
    /// @param tokenId The NFT to find the approved address for
    /// @return operator The approved address for this NFT, or the zero address if none
    function getApproved(uint256 tokenId) external view returns (address operator);

    /// @notice Enable or disable approval for a third party to manage all of an owner's assets
    function setApprovalForAll(address operator, bool approved) external;

    /// @notice Query if an address is an authorized operator for another address
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
