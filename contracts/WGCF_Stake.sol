// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function sub0(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a - b : 0;
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
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init_unchained () virtual internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract Governable is Initializable {
    address public governor;

    event GovernorshipTransferred(address indexed previousGovernor, address indexed newGovernor);

    /**
     * @dev Contract initializer.
     * called once by the factory at time of deployment
     */
    function __Governable_init_unchained(address governor_) virtual internal initializer {
        governor = governor_;
        emit GovernorshipTransferred(address(0), governor);
    }

    modifier governance() {
        require(msg.sender == governor, '!governance');
        _;
    }

    /**
     * @dev Allows the current governor to relinquish control of the contract.
     * @notice Renouncing to governorship will leave the contract without an governor.
     * It will not be possible to call the functions with the `governance`
     * modifier anymore.
     */
    function renounceGovernorship() public governance {
        emit GovernorshipTransferred(governor, address(0));
        governor = address(0);
    }

    /**
     * @dev Allows the current governor to transfer control of the contract to a newGovernor.
     * @param newGovernor The address to transfer governorship to.
     */
    function transferGovernorship(address newGovernor) public governance {
        _transferGovernorship(newGovernor);
    }

    /**
     * @dev Transfers control of the contract to a newGovernor.
     * @param newGovernor The address to transfer governorship to.
     */
    function _transferGovernorship(address newGovernor) internal {
        require(newGovernor != address(0));
        emit GovernorshipTransferred(governor, newGovernor);
        governor = newGovernor;
    }
}

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

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
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
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
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata, Initializable {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init_unchained (string memory name_, string memory symbol_) virtual internal initializer {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

contract WGCF_Token is ERC20 {

    using SafeMath for uint;

    uint constant MAX_SUPPLY = 2100 * 1e4 * 1e18;

    uint private _circulationSupply;

    Locker[2] public lockers;

    struct Locker {
        address recipient;
        uint releaseAt;
        uint amount;
        uint countdown;
    }

    function __WGCF_Token_init_unchained (address lock1, address lock2) virtual internal initializer {
        __ERC20_init_unchained("WGCF", "WGCF");
        _mint(msg.sender, 100 * 1e4 * 1e18);
        addCirculationSupply(100 * 1e4 * 1e18);
        lockers[0] = Locker(lock1, block.timestamp.add(6 * 30 days), 60000 * 1e18, 5);
        lockers[1] = Locker(lock2, block.timestamp.add(6 * 30 days), 40000 * 1e18, 5);
    }

    function claimCoin() public {
        uint amount = checkRelease(msg.sender);
        require(amount > 0, "WGCF: can not release 0");
        Locker[2] memory _lockers = lockers;
        for (uint index = 0; index < _lockers.length; index ++) {
            if (msg.sender == _lockers[index].recipient) {
                lockers[index].countdown = lockers[index].countdown.sub(1);
                lockers[index].releaseAt = lockers[index].releaseAt.add(30 days);
                _mint(msg.sender, amount);
                addCirculationSupply(amount);
            }
        }
    }

    function checkRelease(address account) public view returns (uint amount) {
        amount = 0;
        Locker[2] memory _lockers = lockers;
        for (uint index = 0; index < _lockers.length; index ++) {
            if (account == _lockers[index].recipient) {
                if (block.timestamp >= _lockers[index].releaseAt && _lockers[index].countdown > 0)
                {
                    amount = _lockers[index].amount;
                    break;
                }
            }
        }
    }

    function _mint(address account, uint amount) internal override {
        require(amount.add(totalSupply()) <= MAX_SUPPLY, "over max Supply");
        super._mint(account, amount);
    }

    function circulationSupply() public view returns (uint) {
        return _circulationSupply;
    }

    function addCirculationSupply(uint amount) internal {
        _circulationSupply = _circulationSupply.add(amount);
    }

}

contract WGCF_Stake is ReentrancyGuard, Governable, WGCF_Token {

    using SafeMath for uint;

    // constant
    uint public constant DURATION = 3 * 365 days;
    uint public constant REWARD_ROUND = 5;
    uint public constant INIT_REWARD = 9216 * 3 * 365 * 1e18;
    uint public constant TOTAL_REWARD = 1950 * 1e4 * 1e18;
    uint public constant MAX_REWARD_PER_ORDER = 30 days;
    address public constant BURN_ADDRESS = address(0x0000000000000000000000000000000000000001);

    // struct
    struct StakeOrder {
        uint amount;
        uint createAt;
        uint lastUpdateTime;
    }

    struct UserInfo {
        address father;
        uint promotedAmount;
        uint[5] umbStakedAmounts;
        mapping(address => uint) umbStakedReward;
    }

    // variable field
    uint public currentRound;
    uint public initReward;
    uint public startTime;
    uint public periodFinish;
    uint public rewardRate;
    uint public lastUpdateTime;
    uint public rewardPerTokenStored;

    uint private _totalStaked;
    uint private _totalPromoted;
    mapping(address => UserInfo) private _userInfo;
    mapping(address => StakeOrder) private _stakeOrder;
    mapping(address => uint) public userRewardPerTokenPaid;
    mapping(address => uint) public rewards;

    // add
    uint private _totalBurn;
    mapping(address => uint) public claimedReward;

    // event
    event RewardAdded(uint reward);
    event Staked(address indexed user, uint amount);
    event Withdrawn(address indexed user, uint amount);
    event RewardPaid(address indexed user, uint reward);

    // modifier
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
            _stakeOrder[account].lastUpdateTime = Math.min(lastUpdateTime, _stakeOrder[account].createAt.add(MAX_REWARD_PER_ORDER));
        }
        _;
    }

    modifier checkStart() {
        require(block.timestamp >= startTime, "WGCF: not start");
        _;
    }

    modifier checkOrderExpired(address account) {
        uint expireAt = _stakeOrder[account].createAt.add(MAX_REWARD_PER_ORDER);
        require(block.timestamp >= expireAt, "WGCF: order not expired");
        _;
    }

    modifier checkHalve() {
        if (block.timestamp >= periodFinish && currentRound < REWARD_ROUND) {
            uint _initReward = initReward.mul(50).div(100);
            initReward = Math.min(_initReward, MAX_SUPPLY.sub(totalSupply()));
            _mint(address(this), initReward);
            rewardRate = initReward.div(DURATION);
            periodFinish = block.timestamp.add(DURATION);
            currentRound ++;
            emit RewardAdded(initReward);
        }
        _;
    }

    // initialize function
    function __WGCF_Stake_init(address _governor, address _stakeRoot, address lock1, address lock2) external initializer {
        __Governable_init_unchained(_governor);
        __WGCF_Token_init_unchained(lock1, lock2);
        __WGCF_Stake_init_unchained(_stakeRoot);
    }

    function __WGCF_Stake_init_unchained(address _stakeRoot) private governance {
        currentRound = 1;
        initReward = INIT_REWARD;
        _mint(address(this), initReward);
        rewardRate = initReward.div(DURATION);
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(DURATION);

        emit RewardAdded(initReward);

        _userInfo[_stakeRoot].father = BURN_ADDRESS;
        _stakeOrder[_stakeRoot].createAt = block.timestamp;
    }

    // pure function
    function umbLevel() public pure returns (uint[15] memory) {
        uint[15] memory levels = [uint(0), 1, 1, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4];
        return levels;
    }

    function testCondition() public pure returns (uint[15] memory) {
        uint[15] memory condition =
        [
            uint(20 * 1e18),
            60 * 1e18, 60 * 1e18,
            200 * 1e18, 200 * 1e18,
            600 * 1e18, 600 * 1e18, 600 * 1e18, 600 * 1e18, 600 * 1e18,
            2000 * 1e18, 2000 * 1e18, 2000 * 1e18, 2000 * 1e18, 2000 * 1e18
        ];
        return condition;
    }

    // view function
    function userInfo(address account) public view returns (address father, uint promoted, uint[5] memory levels) {
        UserInfo memory user = _userInfo[account];
        father = user.father;
        promoted = user.promotedAmount;
        levels = user.umbStakedAmounts;
    }

    function stakeOrder(address account) public view returns (uint amount, uint expireAt) {
        StakeOrder memory order = _stakeOrder[account];
        amount = order.amount;
        expireAt = order.createAt.add(MAX_REWARD_PER_ORDER);
    }

    function totalHash() public view returns (uint) {
        return _totalStaked.add(_totalPromoted);
    }

    function totalStaked() public view returns (uint) {
        return _totalStaked;
    }

    function totalPromoted() public view returns (uint) {
        return _totalPromoted;
    }

    function totalBurn() public view returns (uint) {
        return _totalBurn;
    }

    function rewardsRemaining() public view returns (uint) {
        uint output = 0;
        for (uint round = 0; round < currentRound; round ++) {
            if (round + 1 >= currentRound) {
                uint remainingTime = periodFinish.sub(block.timestamp);
                output = output.add(initReward.sub(remainingTime.mul(rewardRate)));
                continue;
            }

            output = output.add(INIT_REWARD.div(2**round));
        }

        return TOTAL_REWARD.sub(output);
    }

    function rewardsPerT() public view returns (uint) {
        uint rewardsPerDay = rewardRate.mul(1 days);
        return totalHash() == 0 ? rewardsPerDay : rewardsPerDay.mul(20 * 1e18).div(totalHash());
    }

    function lastTimeRewardApplicable() public view returns (uint) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint) {
        if (totalHash() == 0) {
            return rewardPerTokenStored;
        }
        return
        rewardPerTokenStored.add(
            lastTimeRewardApplicable()
            .sub(lastUpdateTime)
            .mul(rewardRate)
            .mul(1e18)
            .div(totalHash())
        );
    }

    function earned(address account) public view returns (uint) {
        uint _rewardPerToken = rewardPerToken();
        uint userRewardUnPaid = _rewardPerToken.sub(userRewardPerTokenPaid[account]);
        UserInfo memory user = _userInfo[account];
        StakeOrder memory order = _stakeOrder[account];
        uint stakeReward = order.amount.mul(userRewardUnPaid).div(1e18);
        uint promoteReward = user.promotedAmount.mul(userRewardUnPaid).div(1e18);
        uint expireAt = order.createAt.add(MAX_REWARD_PER_ORDER);
        // ReCalc If Expired
        if (lastTimeRewardApplicable() > expireAt) {
            uint totalTime = lastTimeRewardApplicable().sub(order.lastUpdateTime);
            uint excludedTime = lastTimeRewardApplicable().sub(expireAt);
            stakeReward = stakeReward.sub(stakeReward.mul(excludedTime).div(totalTime));
            promoteReward = promoteReward.sub(promoteReward.mul(excludedTime).div(totalTime));
        }

        return stakeReward.add(promoteReward).add(rewards[account]);
    }

    function promotedAmount(address account) public view returns (uint) {
        uint amount = 0;
        uint[5] memory umbStakedAmounts = _userInfo[account].umbStakedAmounts;
        for (uint index = 0; index < umbStakedAmounts.length; index ++)
            amount = amount.add(umbStakedAmounts[index]);

        return amount;
    }

    function availableAmount(address account) private view returns (uint balance) {
        StakeOrder memory order = _stakeOrder[account];
        uint expireAt = order.createAt.add(MAX_REWARD_PER_ORDER);

        balance = expireAt > block.timestamp ? order.amount : 0;
    }

    // rate in (1/10000)
    function destroyRate() public view returns (uint rate) {
        if (_totalStaked < 100000 * 20 * 1e18) return 300;
        if (_totalStaked < 200000 * 20 * 1e18) return 150;
        if (_totalStaked < 300000 * 20 * 1e18) return 75;
        if (_totalStaked < 400000 * 20 * 1e18) return 40;
        if (_totalStaked < 500000 * 20 * 1e18) return 20;
        if (_totalStaked < 600000 * 20 * 1e18) return 10;
        return 0;
    }

    // modify function
    function stake(uint amount, address father) public
    nonReentrant
    updateReward(msg.sender)
    checkStart
    checkOrderExpired(msg.sender)
    checkHalve
    {
        require(_stakeOrder[father].createAt > 0, "WGCF: invalid invitor" );
        require(amount > 0, "WGCF: cannot stake 0");
        require(amount % (20 * 1e18) == 0, "WGCF: not multiples of 20");

        // save father
        if (_userInfo[msg.sender].father == address(0))
            _userInfo[msg.sender].father = father;

        _totalStaked = _totalStaked.add(amount);

        // update order
        StakeOrder storage order = _stakeOrder[msg.sender];
        order.createAt = block.timestamp;
        order.amount = amount;
        order.lastUpdateTime = block.timestamp;

        // distribution to ancestors
        uint promoteAmount = amount.div(10);
        address currentUser = _userInfo[msg.sender].father;
        uint[15] memory levels = umbLevel();
        uint[15] memory condition = testCondition();
        for (uint index = 0; index < levels.length; index ++) {
            if (currentUser == address(0)) break;
            UserInfo storage ancestor = _userInfo[currentUser];
            ancestor.umbStakedAmounts[levels[index]] = ancestor.umbStakedAmounts[levels[index]].add(amount);
            if (availableAmount(currentUser) >= condition[index]) {
                _totalPromoted = _totalPromoted.add(promoteAmount);
                ancestor.promotedAmount = ancestor.promotedAmount.add(promoteAmount);
                ancestor.umbStakedReward[msg.sender] = promoteAmount;
            }
            currentUser = ancestor.father;
        }

        // transfer token
        TransferHelper.safeTransferFrom(address(this), msg.sender, address(this), amount);

        emit Staked(msg.sender, amount);
    }

    function withdraw() public
    nonReentrant
    updateReward(msg.sender)
    checkStart
    checkOrderExpired(msg.sender)
    checkHalve
    {
        StakeOrder memory order = _stakeOrder[msg.sender];
        require(order.amount > 0, "WGCF: cannot withdraw 0");

        // update order
        _totalStaked = _totalStaked.sub(order.amount);
        _stakeOrder[msg.sender].amount = 0;

        // distribution to ancestors
        uint promoteAmount = order.amount.div(10);
        address currentUser = _userInfo[msg.sender].father;
        uint[15] memory levels = umbLevel();
        for (uint index = 0; index < levels.length; index ++) {
            if (currentUser == address(0)) break;
            UserInfo storage ancestor = _userInfo[currentUser];
            ancestor.umbStakedAmounts[levels[index]] = ancestor.umbStakedAmounts[levels[index]].sub(order.amount);
            if (ancestor.umbStakedReward[msg.sender] > 0) {
                _totalPromoted = _totalPromoted.sub(promoteAmount);
                ancestor.promotedAmount = ancestor.promotedAmount.sub(promoteAmount);
                ancestor.umbStakedReward[msg.sender] = 0;
            }
            currentUser = ancestor.father;
        }

        // transfer
        // safeTransfer(msg.sender, );
        // safeTransfer(address(0), );
        uint destroyAmount = order.amount.mul(destroyRate()).div(10000);
        _totalBurn = _totalBurn.add(destroyAmount);
        TransferHelper.safeTransfer(address(this), BURN_ADDRESS, destroyAmount);
        TransferHelper.safeTransfer(address(this), msg.sender, order.amount.sub(destroyAmount));

        emit Withdrawn(msg.sender, order.amount);
    }

    function getReward() public
    nonReentrant
    updateReward(msg.sender)
    checkStart
    checkHalve
    {
        uint reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            addCirculationSupply(reward);
            claimedReward[msg.sender] = claimedReward[msg.sender].add(reward);
            // saferTransfer
            TransferHelper.safeTransfer(address(this), msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

}
