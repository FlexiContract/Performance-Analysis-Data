// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
//Complex Score 160
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract EternalStorage {
    mapping(bytes32 => uint256) private uintStorage;
    mapping(bytes32 => string) private stringStorage;
    mapping(bytes32 => address) private addressStorage;
    mapping(bytes32 => bytes) private bytesStorage;
    mapping(bytes32 => bool) private boolStorage;
    mapping(bytes32 => int256) private intStorage;

    function getUint(bytes32 _key) public view returns (uint256) {
        return uintStorage[_key];
    }

    function setUint(bytes32 _key, uint256 _value) public {
        uintStorage[_key] = _value;
    }

    function getString(bytes32 _key) public view returns (string memory) {
        return stringStorage[_key];
    }

    function setString(bytes32 _key, string memory _value) public {
        stringStorage[_key] = _value;
    }

    function getAddress(bytes32 _key) public view returns (address) {
        return addressStorage[_key];
    }

    function setAddress(bytes32 _key, address _value) public {
        addressStorage[_key] = _value;
    }

    function getBytes(bytes32 _key) public view returns (bytes memory) {
        return bytesStorage[_key];
    }

    function setBytes(bytes32 _key, bytes memory _value) public {
        bytesStorage[_key] = _value;
    }

    function getBool(bytes32 _key) public view returns (bool) {
        return boolStorage[_key];
    }

    function setBool(bytes32 _key, bool _value) public {
        boolStorage[_key] = _value;
    }

    function getInt(bytes32 _key) public view returns (int256) {
        return intStorage[_key];
    }

    function setInt(bytes32 _key, int256 _value) public {
        intStorage[_key] = _value;
    }
}

contract ERC20 is IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    EternalStorage private eternalStorage;

    bytes32 private constant TOTAL_SUPPLY = keccak256("TOTAL_SUPPLY");
    bytes32 private constant BALANCE_OF = keccak256("BALANCE_OF");
    bytes32 private constant ALLOWANCE = keccak256("ALLOWANCE");
    bytes32 private constant NAME = keccak256("NAME");
    bytes32 private constant SYMBOL = keccak256("SYMBOL");
    bytes32 private constant DECIMALS = keccak256("DECIMALS");

    constructor(address _eternalStorage, string memory _name, string memory _symbol, uint8 _decimals) {
        eternalStorage = EternalStorage(_eternalStorage);
        eternalStorage.setString(NAME, _name);
        eternalStorage.setString(SYMBOL, _symbol);
        eternalStorage.setUint(DECIMALS, _decimals);
    }

    function name() public view returns (string memory) {
        return eternalStorage.getString(NAME);
    }

    function symbol() public view returns (string memory) {
        return eternalStorage.getString(SYMBOL);
    }

    function decimals() public view returns (uint8) {
        return uint8(eternalStorage.getUint(DECIMALS));
    }

    function totalSupply() public view override returns (uint256) {
        return eternalStorage.getUint(TOTAL_SUPPLY);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return eternalStorage.getUint(keccak256(abi.encodePacked(BALANCE_OF, account)));
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return eternalStorage.getUint(keccak256(abi.encodePacked(ALLOWANCE, owner, spender)));
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = allowance(sender, msg.sender);
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = balanceOf(sender);
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            eternalStorage.setUint(keccak256(abi.encodePacked(BALANCE_OF, sender)), senderBalance - amount);
            eternalStorage.setUint(keccak256(abi.encodePacked(BALANCE_OF, recipient)), balanceOf(recipient) + amount);
        }

        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        eternalStorage.setUint(keccak256(abi.encodePacked(ALLOWANCE, owner, spender)), amount);
        emit Approval(owner, spender, amount);
    }

    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "ERC20: mint to the zero address");

        eternalStorage.setUint(TOTAL_SUPPLY, totalSupply() + amount);
        eternalStorage.setUint(keccak256(abi.encodePacked(BALANCE_OF, to)), balanceOf(to) + amount);
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        require(from != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = balanceOf(from);
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            eternalStorage.setUint(keccak256(abi.encodePacked(BALANCE_OF, from)), accountBalance - amount);
        }
        eternalStorage.setUint(TOTAL_SUPPLY, totalSupply() - amount);

        emit Transfer(from, address(0), amount);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}

contract MyToken is ERC20 {
    constructor(address _eternalStorage, string memory _name, string memory _symbol, uint8 _decimals)
        ERC20(_eternalStorage, _name, _symbol, _decimals)
    {
        // Mint 100 tokens to msg.sender
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        _mint(msg.sender, 100 * 10 ** uint256(_decimals));
    }
}