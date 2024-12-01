// SPDX-License-Identifier: MIT
// Specifies the license under which the contract is published.

pragma solidity ^0.8.0;
// Specifies the Solidity compiler version to be used.

// Context Contract
// Provides basic contextual information about the current execution environment.
contract Context {
    // Returns the address of the caller of the current function.
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    // Returns the calldata of the current function call.
    function _msgData() internal pure returns (bytes calldata) {
        return msg.data;
    }
}

// IERC20 Interface
// Defines the standard ERC20 token interface, including mandatory functions and events.
interface IERC20 {
    // Returns the total supply of tokens.
    function totalSupply() external view returns (uint256);

    // Returns the token balance of a specific account.
    function balanceOf(address account) external view returns (uint256);

    // Transfers tokens to a recipient.
    function transfer(address recipient, uint256 amount) external returns (bool);

    // Returns the remaining number of tokens that a spender is allowed to spend on behalf of the owner.
    function allowance(address owner, address spender) external view returns (uint256);

    // Approves a spender to spend a specified amount of tokens on behalf of the caller.
    function approve(address spender, uint256 amount) external returns (bool);

    // Transfers tokens from a sender to a recipient using an allowance mechanism.
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    // Emitted when tokens are transferred.
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Emitted when an allowance is set or updated.
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// IERC20Metadata Interface
// Extends the IERC20 interface with optional metadata functions.
interface IERC20Metadata is IERC20 {
    // Returns the name of the token.
    function name() external view returns (string memory);

    // Returns the symbol of the token.
    function symbol() external view returns (string memory);

    // Returns the number of decimals used to get token amounts.
    function decimals() external view returns (uint8);
}

// Ownable Contract
// Provides a basic access control mechanism, where an owner account can execute specific functions.
contract Ownable is Context {
    address private _owner;

    // Emitted when ownership of the contract is transferred.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Initializes the contract and sets the deployer as the initial owner.
    constructor() {
        _transferOwnership(_msgSender());
    }

    // Returns the address of the current owner.
    function owner() public view virtual returns (address) {
        return _owner;
    }

    // Modifier that restricts access to only the owner.
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    // Allows the owner to renounce ownership, leaving the contract without an owner.
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    // Transfers ownership to a new owner.
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    // Internal function to handle ownership transfer.
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// COINGT Contract
// Implementation of an ERC20 token with additional ownership-based minting and burning functionality.
contract COINGT is Context, IERC20, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances; // Stores token balances of accounts.

    mapping(address => mapping(address => uint256)) private _allowances; // Stores allowances set by token holders.

    uint256 private _totalSupply; // Total supply of the token.

    string private _name; // Token name.
    string private _symbol; // Token symbol.
    uint8 private _decimals; // Token decimals.

    // Constructor initializes token name, symbol, decimals, and mints initial supply to the deployer.
    constructor() {
        _name = "COINGT";
        _symbol = "COINGT";
        _decimals = 0;
        _mint(msg.sender, 195_770);
    }

    // Returns the name of the token.
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    // Returns the symbol of the token.
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    // Returns the number of decimals for token amounts.
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    // Returns the total supply of tokens.
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    // Returns the balance of a specific account.
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    // Transfers tokens to a recipient.
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    // Returns the allowance set by the owner for a spender.
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    // Approves a spender to spend a specified amount of tokens.
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    // Transfers tokens using an allowance mechanism.
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    // Increases the allowance for a spender.
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    // Decreases the allowance for a spender.
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    // Mints new tokens to a specified account. Restricted to the owner.
    function mint(address account, uint256 value) public onlyOwner {
        _mint(account, value);
    }

    // Burns tokens from a specified account. Restricted to the owner.
    function burn(address account, uint256 value) public onlyOwner {
        _burn(account, value);
    }

    // Internal function to handle token transfers.
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    // Internal function to mint new tokens.
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    // Internal function to burn tokens.
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    // Internal function to set allowances.
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // Hook for custom logic before token transfers.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    // Hook for custom logic after token transfers.
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
