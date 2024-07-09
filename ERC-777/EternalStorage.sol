// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
// Complex Score 349
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC777 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the smallest part of the token that is not divisible. This
     * means all token operations (creation, movement and destruction) must have
     * amounts that are a multiple of this number.
     *
     * For most token contracts, this value will equal 1.
     */
    function granularity() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by an account (`owner`).
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * If send or receive hooks are registered for the caller and `recipient`,
     * the corresponding functions will be called with `data` and empty
     * `operatorData`. See `IERC777Sender` and `IERC777Recipient`.
     *
     * Emits a `Sent` event.
     *
     * Requirements
     *
     * - the caller must have at least `amount` tokens.
     * - `recipient` cannot be the zero address.
     * - if `recipient` is a contract, it must implement the `tokensReceived`
     * interface.
     */
    function send(address recipient, uint256 amount, bytes calldata data) external;

    /**
     * @dev Destroys `amount` tokens from the caller's account, reducing the
     * total supply.
     *
     * If a send hook is registered for the caller, the corresponding function
     * will be called with `data` and empty `operatorData`. See `IERC777Sender`.
     *
     * Emits a `Burned` event.
     *
     * Requirements
     *
     * - the caller must have at least `amount` tokens.
     */
    function burn(uint256 amount, bytes calldata data) external;

    /**
     * @dev Returns true if an account is an operator of `tokenHolder`.
     * Operators can send and burn tokens on behalf of their owners. All
     * accounts are their own operator.
     *
     * See `operatorSend` and `operatorBurn`.
     */
    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);

    /**
     * @dev Make an account an operator of the caller.
     *
     * See `isOperatorFor`.
     *
     * Emits an `AuthorizedOperator` event.
     *
     * Requirements
     *
     * - `operator` cannot be calling address.
     */
    function authorizeOperator(address operator) external;

    /**
     * @dev Make an account an operator of the caller.
     *
     * See `isOperatorFor` and `defaultOperators`.
     *
     * Emits a `RevokedOperator` event.
     *
     * Requirements
     *
     * - `operator` cannot be calling address.
     */
    function revokeOperator(address operator) external;

    /**
     * @dev Returns the list of default operators. These accounts are operators
     * for all token holders, even if `authorizeOperator` was never called on
     * them.
     *
     * This list is immutable, but individual holders may revoke these via
     * `revokeOperator`, in which case `isOperatorFor` will return false.
     */
    function defaultOperators() external view returns (address[] memory);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient`. The caller must
     * be an operator of `sender`.
     *
     * If send or receive hooks are registered for `sender` and `recipient`,
     * the corresponding functions will be called with `data` and
     * `operatorData`. See `IERC777Sender` and `IERC777Recipient`.
     *
     * Emits a `Sent` event.
     *
     * Requirements
     *
     * - `sender` cannot be the zero address.
     * - `sender` must have at least `amount` tokens.
     * - the caller must be an operator for `sender`.
     * - `recipient` cannot be the zero address.
     * - if `recipient` is a contract, it must implement the `tokensReceived`
     * interface.
     */
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    /**
     * @dev Destoys `amount` tokens from `account`, reducing the total supply.
     * The caller must be an operator of `account`.
     *
     * If a send hook is registered for `account`, the corresponding function
     * will be called with `data` and `operatorData`. See `IERC777Sender`.
     *
     * Emits a `Burned` event.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     * - the caller must be an operator for `account`.
     */
    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}

interface IERC777Recipient {
    /**
     * @dev Called by an `IERC777` token contract whenever tokens are being
     * moved or created into a registered account (`to`). The type of operation
     * is conveyed by `from` being the zero address or not.
     *
     * This call occurs _after_ the token contract's state is updated, so
     * `IERC777.balanceOf`, etc., can be used to query the post-operation state.
     *
     * This function may revert to prevent the operation from being executed.
     */
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}

interface IERC777Sender {
    /**
     * @dev Called by an `IERC777` token contract whenever a registered holder's
     * (`from`) tokens are about to be moved or destroyed. The type of operation
     * is conveyed by `to` being the zero address or not.
     *
     * This call occurs _before_ the token contract's state is updated, so
     * `IERC777.balanceOf`, etc., can be used to query the pre-operation state.
     *
     * This function may revert to prevent the operation from being executed.
     */
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}

interface IERC1820Registry {
    /**
     * @dev Sets `newManager` as the manager for `account`. A manager of an
     * account is able to set interface implementers for it.
     *
     * By default, each account is its own manager. Passing a value of `0x0` in
     * `newManager` will reset the manager to this initial state.
     *
     * Emits a `ManagerChanged` event.
     *
     * Requirements:
     *
     * - the caller must be the current manager for `account`.
     */
    function setManager(address account, address newManager) external;

    /**
     * @dev Returns the manager for `account`.
     *
     * See `setManager`.
     */
    function getManager(address account) external view returns (address);

    /**
     * @dev Sets the `implementer` contract as `account`'s implementer for
     * `interfaceHash`.
     *
     * `account` being the zero address is an alias for the caller's address.
     * The zero address can also be used in `implementer` to remove an old one.
     *
     * See `interfaceHash` to learn how these are created.
     *
     * Emits an `InterfaceImplementerSet` event.
     *
     * Requirements:
     *
     * - the caller must be the current manager for `account`.
     * - `interfaceHash` must not be an `IERC165` interface id (i.e. it must not
     * end in 28 zeroes).
     * - `implementer` must implement `IERC1820Implementer` and return true when
     * queried for support, unless `implementer` is the caller. See
     * `IERC1820Implementer.canImplementInterfaceForAddress`.
     */
    function setInterfaceImplementer(address account, bytes32 interfaceHash, address implementer) external;

    /**
     * @dev Returns the implementer of `interfaceHash` for `account`. If no such
     * implementer is registered, returns the zero address.
     *
     * If `interfaceHash` is an `IERC165` interface id (i.e. it ends with 28
     * zeroes), `account` will be queried for support of it.
     *
     * `account` being the zero address is an alias for the caller's address.
     */
    function getInterfaceImplementer(address account, bytes32 interfaceHash) external view returns (address);

    /**
     * @dev Returns the interface hash for an `interfaceName`, as defined in the
     * corresponding
     * [section of the EIP](https://eips.ethereum.org/EIPS/eip-1820#interface-name).
     */
    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);

    /**
     *  @notice Updates the cache with whether the contract implements an ERC165 interface or not.
     *  @param account Address of the contract for which to update the cache.
     *  @param interfaceId ERC165 interface for which to update the cache.
     */
    function updateERC165Cache(address account, bytes4 interfaceId) external;

    /**
     *  @notice Checks whether a contract implements an ERC165 interface or not.
     *  If the result is not cached a direct lookup on the contract address is performed.
     *  If the result is not cached or the cached value is out-of-date, the cache MUST be updated manually by calling
     *  'updateERC165Cache' with the contract address.
     *  @param account Address of the contract to check.
     *  @param interfaceId ERC165 interface to check.
     *  @return True if `account.address()` implements `interfaceId`, false otherwise.
     */
    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);

    /**
     *  @notice Checks whether a contract implements an ERC165 interface or not without using nor updating the cache.
     *  @param account Address of the contract to check.
     *  @param interfaceId ERC165 interface to check.
     *  @return True if `account.address()` implements `interfaceId`, false otherwise.
     */
    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);

    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * > It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract EternalStorage {
    mapping(bytes32 => uint256) private uintStorage;
    mapping(bytes32 => address) private addressStorage;
    mapping(bytes32 => bool) private boolStorage;
    mapping(bytes32 => bytes) private bytesStorage;
    mapping(bytes32 => string) private stringStorage;
    mapping(bytes32 => address[]) private addressArrayStorage;

    function getUint(bytes32 key) external view returns (uint256) {
        return uintStorage[key];
    }

    function setUint(bytes32 key, uint256 value) external {
        uintStorage[key] = value;
    }

    function getAddress(bytes32 key) external view returns (address) {
        return addressStorage[key];
    }

    function setAddress(bytes32 key, address value) external {
        addressStorage[key] = value;
    }

    function getBool(bytes32 key) external view returns (bool) {
        return boolStorage[key];
    }

    function setBool(bytes32 key, bool value) external {
        boolStorage[key] = value;
    }

    function getBytes(bytes32 key) external view returns (bytes memory) {
        return bytesStorage[key];
    }

    function setBytes(bytes32 key, bytes memory value) external {
        bytesStorage[key] = value;
    }

    function getString(bytes32 key) external view returns (string memory) {
        return stringStorage[key];
    }

    function setString(bytes32 key, string memory value) external {
        stringStorage[key] = value;
    }

    function getAddressArrayLength(bytes32 key) external view returns (uint256) {
        return addressArrayStorage[key].length;
    }

    function getAddressArrayElement(bytes32 key, uint256 index) external view returns (address) {
        require(index < addressArrayStorage[key].length, "Index out of bounds");
        return addressArrayStorage[key][index];
    }

    function pushAddressToArray(bytes32 key, address value) external {
        addressArrayStorage[key].push(value);
    }

    function setAddressArray(bytes32 key, address[] memory values) external {
        addressArrayStorage[key] = values;
    }
}

contract ERC777WithEternalStorage is IERC777, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    EternalStorage private eternalStorage;
    IERC1820Registry private _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    // keccak256("ERC777TokensSender")
    bytes32 constant private TOKENS_SENDER_INTERFACE_HASH =
        0x29ddb589b1fb5fc7cf394961c1adf5f8c6454761adf795e67fe149f658abe895;

    // keccak256("ERC777TokensRecipient")
    bytes32 constant private TOKENS_RECIPIENT_INTERFACE_HASH =
        0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

    bytes32 private constant TOTAL_SUPPLY_KEY = keccak256("totalSupply");
    bytes32 private constant NAME_KEY = keccak256("name");
    bytes32 private constant SYMBOL_KEY = keccak256("symbol");
    bytes32 private constant DEFAULT_OPERATORS_KEY = keccak256("defaultOperators");

    //event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
    //event RevokedOperator(address indexed operator, address indexed tokenHolder);
    //event Minted(address indexed operator, address indexed to, uint256 amount, bytes userData, bytes operatorData);
    //event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);
    //event Sent(address indexed operator, address indexed from, address indexed to, uint256 amount, bytes userData, bytes operatorData);
    //event Transfer(address indexed from, address indexed to, uint256 value);
    //event Approval(address indexed holder, address indexed spender, uint256 value);

    constructor(
        string memory nameOfToken,
        string memory symbolOfToken,
        address[] memory defaultOperatorsOfToken,
        address eternalStorageAddress
    ) {
        eternalStorage = EternalStorage(eternalStorageAddress);
        eternalStorage.setString(NAME_KEY, nameOfToken);
        eternalStorage.setString(SYMBOL_KEY, symbolOfToken);

        for (uint256 i = 0; i < defaultOperatorsOfToken.length; i++) {
            bytes32 defaultOperatorKey = keccak256(abi.encodePacked("defaultOperator", defaultOperatorsOfToken[i]));
            eternalStorage.setBool(defaultOperatorKey, true);
            eternalStorage.pushAddressToArray(DEFAULT_OPERATORS_KEY, defaultOperatorsOfToken[i]);
        }

        _erc1820.setInterfaceImplementer(address(this), keccak256("ERC777Token"), address(this));
        _erc1820.setInterfaceImplementer(address(this), keccak256("ERC20Token"), address(this));
    }

    function name() public view returns (string memory) {
        return eternalStorage.getString(NAME_KEY);
    }

    function symbol() public view returns (string memory) {
        return eternalStorage.getString(SYMBOL_KEY);
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function granularity() public pure returns (uint256) {
        return 1;
    }

    function totalSupply() public view override(IERC777, IERC20) returns (uint256) {
        return eternalStorage.getUint(TOTAL_SUPPLY_KEY);
    }

    function balanceOf(address tokenHolder) public view override(IERC777, IERC20) returns (uint256) {
        bytes32 balanceKey = keccak256(abi.encodePacked("balance", tokenHolder));
        return eternalStorage.getUint(balanceKey);
    }

    function send(address recipient, uint256 amount, bytes calldata data) external {
        _send(msg.sender, msg.sender, recipient, amount, data, "", true);
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");

        address from = msg.sender;
        _callTokensToSend(from, from, recipient, amount, "", "");
        _move(from, from, recipient, amount, "", "");
        _callTokensReceived(from, from, recipient, amount, "", "", false);

        return true;
    }

    function burn(uint256 amount, bytes calldata data) external {
        _burn(msg.sender, msg.sender, amount, data, "");
    }

    function isOperatorFor(address operator, address tokenHolder) public view returns (bool) {
        bytes32 defaultOperatorKey = keccak256(abi.encodePacked("defaultOperator", operator));
        bytes32 revokedOperatorKey = keccak256(abi.encodePacked("revokedDefaultOperator", tokenHolder, operator));
        bytes32 operatorKey = keccak256(abi.encodePacked("operator", tokenHolder, operator));

        return operator == tokenHolder ||
            (eternalStorage.getBool(defaultOperatorKey) && !eternalStorage.getBool(revokedOperatorKey)) ||
            eternalStorage.getBool(operatorKey);
    }

    function authorizeOperator(address operator) external {
        require(msg.sender != operator, "ERC777: authorizing self as operator");

        bytes32 defaultOperatorKey = keccak256(abi.encodePacked("defaultOperator", operator));
        bytes32 revokedOperatorKey = keccak256(abi.encodePacked("revokedDefaultOperator", msg.sender, operator));
        bytes32 operatorKey = keccak256(abi.encodePacked("operator", msg.sender, operator));

        if (eternalStorage.getBool(defaultOperatorKey)) {
            eternalStorage.setBool(revokedOperatorKey, false);
        } else {
            eternalStorage.setBool(operatorKey, true);
        }

        emit AuthorizedOperator(operator, msg.sender);
    }

    function revokeOperator(address operator) external {
        require(operator != msg.sender, "ERC777: revoking self as operator");

        bytes32 defaultOperatorKey = keccak256(abi.encodePacked("defaultOperator", operator));
        bytes32 revokedOperatorKey = keccak256(abi.encodePacked("revokedDefaultOperator", msg.sender, operator));
        bytes32 operatorKey = keccak256(abi.encodePacked("operator", msg.sender, operator));

        if (eternalStorage.getBool(defaultOperatorKey)) {
            eternalStorage.setBool(revokedOperatorKey, true);
        } else {
            eternalStorage.setBool(operatorKey, false);
        }

        emit RevokedOperator(operator, msg.sender);
    }

    function defaultOperators() public view returns (address[] memory) {
        uint256 length = eternalStorage.getAddressArrayLength(DEFAULT_OPERATORS_KEY);
        address[] memory defaultOperatorsList = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            defaultOperatorsList[i] = eternalStorage.getAddressArrayElement(DEFAULT_OPERATORS_KEY, i);
        }
        return defaultOperatorsList;
    }

    function allowance(address holder, address spender) public view returns (uint256) {
        bytes32 allowanceKey = keccak256(abi.encodePacked("allowance", holder, spender));
        return eternalStorage.getUint(allowanceKey);
    }

    function approve(address spender, uint256 value) public returns (bool) {
        address holder = msg.sender;
        _approve(holder, spender, value);
        return true;
    }

    function transferFrom(address holder, address recipient, uint256 amount) public returns (bool) {
        require(holder != address(0), "ERC777: transfer from the zero address");
        require(recipient != address(0), "ERC777: transfer to the zero address");

        address spender = msg.sender;

        _callTokensToSend(spender, holder, recipient, amount, "", "");

        bytes32 allowanceKey = keccak256(abi.encodePacked("allowance", holder, spender));
        uint256 currentAllowance = eternalStorage.getUint(allowanceKey);
        require(currentAllowance >= amount, "ERC777: transfer amount exceeds allowance");
        eternalStorage.setUint(allowanceKey, currentAllowance - amount);

        _move(spender, holder, recipient, amount, "", "");

        _callTokensReceived(spender, holder, recipient, amount, "", "", false);

        return true;
    }

    /**
     * @dev See `IERC777.operatorSend`.
     *
     * Emits `Sent` and `Transfer` events.
     */
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    )
    external
    {
        require(isOperatorFor(msg.sender, sender), "ERC777: caller is not an operator for holder");
        _send(msg.sender, sender, recipient, amount, data, operatorData, true);
    }

    /**
     * @dev See `IERC777.operatorBurn`.
     *
     * Emits `Sent` and `Transfer` events.
     */
    function operatorBurn(address account, uint256 amount, bytes calldata data, bytes calldata operatorData) external {
        require(isOperatorFor(msg.sender, account), "ERC777: caller is not an operator for holder");
        _burn(msg.sender, account, amount, data, operatorData);
    }

    function _mint(
        address operator,
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) internal {
        require(account != address(0), "ERC777: mint to the zero address");

        bytes32 totalSupplyKey = keccak256("totalSupply");
        uint256 newTotalSupply = eternalStorage.getUint(totalSupplyKey).add(amount);
        eternalStorage.setUint(totalSupplyKey, newTotalSupply);

        bytes32 balanceKey = keccak256(abi.encodePacked("balance", account));
        uint256 newBalance = eternalStorage.getUint(balanceKey).add(amount);
        eternalStorage.setUint(balanceKey, newBalance);

        _callTokensReceived(operator, address(0), account, amount, userData, operatorData, requireReceptionAck);

        emit Minted(operator, account, amount, userData, operatorData);
        emit Transfer(address(0), account, amount);
    }

    function _send(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) internal {
        require(from != address(0), "ERC777: send from the zero address");
        require(to != address(0), "ERC777: send to the zero address");

        _callTokensToSend(operator, from, to, amount, userData, operatorData);

        _move(operator, from, to, amount, userData, operatorData);

        _callTokensReceived(operator, from, to, amount, userData, operatorData, requireReceptionAck);

        emit Sent(operator, from, to, amount, userData, operatorData);
        emit Transfer(from, to, amount);
    }

    function _burn(
        address operator,
        address from,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) internal {
        require(from != address(0), "ERC777: burn from the zero address");

        _callTokensToSend(operator, from, address(0), amount, data, operatorData);

        bytes32 totalSupplyKey = keccak256("totalSupply");
        uint256 newTotalSupply = eternalStorage.getUint(totalSupplyKey).sub(amount);
        eternalStorage.setUint(totalSupplyKey, newTotalSupply);

        bytes32 balanceKey = keccak256(abi.encodePacked("balance", from));
        uint256 newBalance = eternalStorage.getUint(balanceKey).sub(amount);
        eternalStorage.setUint(balanceKey, newBalance);

        emit Burned(operator, from, amount, data, operatorData);
        emit Transfer(from, address(0), amount);
    }

    function _move(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) private {
        bytes32 balanceFromKey = keccak256(abi.encodePacked("balance", from));
        uint256 newBalanceFrom = eternalStorage.getUint(balanceFromKey).sub(amount);
        eternalStorage.setUint(balanceFromKey, newBalanceFrom);

        bytes32 balanceToKey = keccak256(abi.encodePacked("balance", to));
        uint256 newBalanceTo = eternalStorage.getUint(balanceToKey).add(amount);
        eternalStorage.setUint(balanceToKey, newBalanceTo);

        emit Sent(operator, from, to, amount, userData, operatorData);
        emit Transfer(from, to, amount);
    }

    function _approve(address holder, address spender, uint256 value) private {
        bytes32 allowanceKey = keccak256(abi.encodePacked("allowance", holder, spender));
        eternalStorage.setUint(allowanceKey, value);
        emit Approval(holder, spender, value);
    }

    function _callTokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) private {
        address implementer = _erc1820.getInterfaceImplementer(from, TOKENS_SENDER_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Sender(implementer).tokensToSend(operator, from, to, amount, userData, operatorData);
        }
    }

    function _callTokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) private {
        address implementer = _erc1820.getInterfaceImplementer(to, TOKENS_RECIPIENT_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Recipient(implementer).tokensReceived(operator, from, to, amount, userData, operatorData);
        } else if (requireReceptionAck) {
            require(!to.isContract(), "ERC777: token recipient contract has no implementer for ERC777TokensRecipient");
        }
    }
}

