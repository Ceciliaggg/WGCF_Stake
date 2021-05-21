// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.0;

import "./include/SafeMath.sol";
import "./include/Initializable.sol";
import "./include/ERC20.sol";
import "./include/TransferHelper.sol";

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