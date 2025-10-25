// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./iAssets.sol";

/// @title Assets ERC721 Contract
/// @notice A simple ERC721 implementation for minting and transferring unique digital assets
/// @dev Implements the IERC721 interface
contract Assets is IERC721 {
    /// @notice Token collection name
    string public constant name = "Assets";

    /// @notice Token collection symbol
    string public constant symbol = "AST";
    
    /// @dev Mapping from token ID to owner
    mapping(uint256 => address) private _owners;

    /// @dev Mapping owner address to token count
    mapping(address => uint256) private _balances;

    /// @dev Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    /// @dev Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(uint256 => uint256) private _assetPrices;

    /// @notice Exchange contract allowed to transfer assets during sales
    address public exchange;

    /// @dev Returns whether the given tokenId exists
    /// @param tokenId The NFT identifier to check
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "Zero address not valid");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "Token does not exist");
        return _owners[tokenId];
    }

    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "Token does not exist");
        return _tokenApprovals[tokenId];
    }

    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner, "Not the owner");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != address(0), "Invalid operator");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isAuthorized(from, tokenId), "Not authorized");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        require(_isAuthorized(from, tokenId), "Not authorized");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata) public override {
        require(_isAuthorized(from, tokenId), "Not authorized");
        _transfer(from, to, tokenId);
    }

    function _isAuthorized(address from, uint256 tokenId) internal view returns (bool) {
        address sender = msg.sender;
        return sender == from
            || sender == getApproved(tokenId)
            || isApprovedForAll(from, sender);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "Not owner");
        require(to != address(0), "Invalid address");

        _tokenApprovals[tokenId] = address(0);

        _balances[from] -= 1;
        _balances[to] += 1;

        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /// @notice Registers the Exchange contract that may transfer NFTs during sales
    /// @param exchangeAddress Address of the Exchange proxy or implementation
    function setExchange(address exchangeAddress) external {
        require(exchange == address(0), "Exchange already set");
        require(exchangeAddress != address(0), "Invalid exchange");
        exchange = exchangeAddress;
    }

    /// @notice Transfers an NFT during an Exchange purchase
    /// @dev Caller must be the registered Exchange; seller must have approved the Exchange
    function transferByExchange(address from, address to, uint256 tokenId) external {
        require(msg.sender == exchange, "Only exchange");
        require(
            getApproved(tokenId) == exchange || isApprovedForAll(from, exchange),
            "Exchange not approved"
        );
        _transfer(from, to, tokenId);
    }

    /// @notice Mint a new NFT and assign it to an address
    /// @dev Emits a Transfer event from the zero address
    /// @param to The address that will own the minted NFT
    /// @param tokenId The identifier for the NFT to be minted
    function mint(address to, uint256 tokenId) public {
        require(to != address(0), "Mint to zero address");
        require(!_exists(tokenId), "Token already exists");

        _owners[tokenId] = to;
        _balances[to] += 1;

        emit Transfer(address(0), to, tokenId);
    }

    /// @notice Allows the owner of an NFT to set its price in Coins
    /// @dev The function stores the price in the `_assetPrices` mapping
    /// @param tokenId The identifier of the NFT whose price is being set
    /// @param price The price of the NFT in terms of Coins
    function setAssetPrice(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "Not asset owner");
        _assetPrices[tokenId] = price;
    }

    /// @notice Returns the price of an NFT in Coins
    /// @dev Reverts if the NFT does not exist
    /// @param tokenId The identifier of the NFT whose price is being queried
    /// @return The price of the NFT in Coins
    function getAssetPrice(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "Token does not exist");
        return _assetPrices[tokenId];
    }

}
