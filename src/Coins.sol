// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./iCoins.sol";

/// @title Coins ERC20 Token with Owner Minting Ability
/// @notice ERC20 token that mints 1000 tokens to deployer at deployment
/// @dev Implements IERC20 standard
contract Coins is IERC20 {
    // Token details
    string public constant name = "Coins";
    string public constant symbol = "COIN";
    uint8 public constant decimals = 18;

    // Total supply of tokens
    uint256 private _totalSupply;

    // Owner address
    address public owner;

    /// @notice Exchange contract allowed to pull payments during asset sales
    address public exchange;

    // Mappings for balances and allowances
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    /// @notice Modifier to restrict functions to only the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    /// @notice Constructor mints 1000 tokens to deployer
    constructor() {
        owner = msg.sender; // set contract owner
        uint256 initialSupply = 1000 * (10 ** uint256(decimals));
        _totalSupply = initialSupply;
        _balances[msg.sender] = initialSupply;

        emit Transfer(address(0), msg.sender, initialSupply); // mint event
    }

    /// @notice Registers the Exchange contract that may transfer coins during sales
    /// @param exchangeAddress Address of the Exchange proxy or implementation
    function setExchange(address exchangeAddress) external onlyOwner {
        require(exchangeAddress != address(0), "Invalid exchange");
        exchange = exchangeAddress;
    }

    /// @notice Transfers coins during an Exchange purchase
    /// @dev Caller must be the registered Exchange; buyer must have approved the Exchange
    function transferByExchange(address from, address to, uint256 value) external {
        require(msg.sender == exchange, "Only exchange");
        require(to != address(0), "Invalid recipient");
        require(_balances[from] >= value, "Not enough balance");
        require(_allowances[from][exchange] >= value, "Not approved");

        _balances[from] -= value;
        _balances[to] += value;
        _allowances[from][exchange] -= value;

        emit Transfer(from, to, value);
    }

    /// @notice Mint new tokens to a specified address
    /// @dev Only callable by contract owner
    /// @param to The address that will receive the tokens
    /// @param amount The number of tokens to mint (without decimals adjustment)
    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Invalid address");

        uint256 mintAmount = amount;
        _totalSupply += mintAmount;
        _balances[to] += mintAmount;

        emit Transfer(address(0), to, mintAmount);
    }

    /// @inheritdoc IERC20
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /// @inheritdoc IERC20
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /// @inheritdoc IERC20
    function allowance(address owner_, address spender) public view override returns (uint256) {
        return _allowances[owner_][spender];
    }

    /// @inheritdoc IERC20
    function transfer(address to, uint256 value) public override returns (bool success) {
        require(to != address(0), "Invalid recipient");
        require(_balances[msg.sender] >= value, "Not enough balance");

        _balances[msg.sender] -= value;
        _balances[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    /// @inheritdoc IERC20
    function approve(address spender, uint256 value) public override returns (bool success) {
        require(spender != address(0), "Invalid spender");

        _allowances[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);
        return true;
    }

    /// @inheritdoc IERC20
    function transferFrom(address from, address to, uint256 value) public override returns (bool success) {
        require(to != address(0), "Invalid recipient");
        require(_balances[from] >= value, "Not enough balance");
        require(_allowances[from][msg.sender] >= value, "Not approved");

        _balances[from] -= value;
        _balances[to] += value;
        _allowances[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }
}

