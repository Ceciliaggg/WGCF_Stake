// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.0;

import "./include/SafeMath.sol";
import "./include/Math.sol";
import "./include/Initializable.sol";
import "./include/ReentrancyGuard.sol";
import "./include/Governable.sol";
import "./include/TransferHelper.sol";
import "./WGCF_Token.sol";

contract WGCF_Stake is ReentrancyGuard, Governable, WGCF_Token {

    using SafeMath for uint;

    // constant
    uint public constant DURATION = 3 * 365 days;
    uint public constant REWARD_ROUND = 5;
    uint public constant INIT_REWARD = 9216 * 3 * 365 * 1e18;
    uint public constant TOTAL_REWARD = 1950 * 1e4 * 1e18;
    uint public constant MAX_REWARD_PER_ORDER = 20 * 60;// 30 days;
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
                output = output.add(remainingTime.mul(rewardRate));
                continue;
            }

            output = output.add(INIT_REWARD.div(2**round));
        }

        return output;
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