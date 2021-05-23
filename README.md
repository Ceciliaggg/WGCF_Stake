# WGCF_Stake

主要逻辑：总共发行2100万WGCF，一开始有100万流通；初始有两个锁仓账号，都是6个月后释放第一笔，后面每月释放一笔，5次释放完。其中一个总共释放30万币，另一个释放20万币。用户存入WGCF挖WGCF，初始每天产9216枚币，每三年减半，直至总量到2100万为止。每个用户每次只能质押一次，由于前端存在20枚币为1T算力的概念，因为存入限制为20的整数倍。每次质押后，周期为30天，中间不可提取本金，30天后停止挖矿，用户需提取本金重新质押。


WGCF_Token.sol

claimCoin(): 锁仓账号提取已释放的币

checkRelease(address account): 检查账号当前已释放了多少锁仓的币

_mint(address account, uint amount): 重写ERC20标准的 _mint ，增加总量限制


WGCF_Stake.sol

modifier checkHalve(): 减半函数

earned(address account): 查询用户当前可提收益，如果订单过期，则使用平均值计算实际收益

stake(uint amount, address father): 用户质押币，需要邀请人有效才可以进行，质押成功后给 15 级推荐奖励

withdraw(): 提取本金，并扣除 15 级的推荐奖励

getReward(): 获取收益
