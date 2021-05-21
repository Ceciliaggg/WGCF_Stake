/*global artifacts, web3, contract, before, it, context*/
/*eslint no-undef: "error"*/

const { expect } = require('chai');
const { constants, time, expectRevert, expectEvent } = require('@openzeppelin/test-helpers');
const WGCF_Stake = artifacts.require('WGCF_Stake');

const { toWei, fromWei } = web3.utils;

contract('WGCF_Stake', (accounts) => {

    if (accounts.length < 20) {
        throw new Exception('');
    }

    let wgcfStake;
    let INIT_REWARD = BigInt(9216 * 3 * 365 * 1000000000000000000);
    let TOTAL_REWARD = BigInt(1950 * 1e4 * 1000000000000000000);
    let DURATION = BigInt(3 * 365 * 24 * 60 * 60);
    let initAmount = toWei(`${100 * 1e4}`);
    let governor = accounts[0];
    let root = accounts[0];
    let stakeAmount;
    let lock1 = accounts[18];
    let lock2 = accounts[19];

    before('!! deploy setup', async () => {
        wgcfStake = await WGCF_Stake.new();
        await wgcfStake.__WGCF_Stake_init(governor, root, lock1, lock2);
    });
    context('» contract is not initialized yet', () => {
        context('» parameters are valid', () => {
            it('it initializes contract', async () => {
                wgcfStake = await WGCF_Stake.new();
                await wgcfStake.__WGCF_Stake_init(governor, root, lock1, lock2);
            });
        });
        context('» check governor', () => {
            it('returns correct governor', async () => {
                expect(governor).to.equal(await wgcfStake.governor());
            });
        });
    });
    context('» contract is already initialized', () => {
        before('!! deploy setup', async () => {
            wgcfStake = await WGCF_Stake.new();
            await wgcfStake.__WGCF_Stake_init(governor, root, lock1, lock2);
        });
        // contract has already been initialized during setup
        it('it reverts', async () => {
            await expectRevert(wgcfStake.__WGCF_Stake_init(governor, root, lock1, lock2), 'Contract instance has already been initialized');
        });
        it('check deploying account balance', async () => {
            expect(initAmount).to.equal((await wgcfStake.balanceOf(governor)).toString());
        });
    });

    context('# stake', () => {
        context('» generics', () => {
            context('» stake parameter is not valid', () => {
                before('!! deploy setup', async () => {
                    wgcfStake = await WGCF_Stake.new();
                    await wgcfStake.__WGCF_Stake_init(governor, root, lock1, lock2);
                    stakeAmount = toWei(`200`)
                    await wgcfStake.transfer(accounts[1], stakeAmount);
                    await wgcfStake.approve(wgcfStake.address, stakeAmount, {from: accounts[1]});
                });
                it('should stake with 0 address', async () => {
                    await expectRevert(wgcfStake.stake(stakeAmount, constants.ZERO_ADDRESS, {from: accounts[1]}), 'WGCF: invalid invitor');
                });
                it('stake wrong amount', async () => {
                    await expectRevert(wgcfStake.stake('0', root, {from: accounts[1]}), 'WGCF: cannot stake 0');
                    await expectRevert(wgcfStake.stake(toWei('21'), root, {from: accounts[1]}), 'WGCF: not multiples of 20');
                    let amountOverBalance = toWei(`400`);
                    await wgcfStake.approve(wgcfStake.address, amountOverBalance, {from: accounts[1]});
                    await expectRevert(wgcfStake.stake(amountOverBalance, root, {from: accounts[1]}), 'TransferHelper::transferFrom: transferFrom failed');
                });
                it('stake twice', async () => {
                    await wgcfStake.stake(stakeAmount, root, {from: accounts[1]});
                    await wgcfStake.transfer(accounts[1], stakeAmount);
                    await wgcfStake.approve(wgcfStake.address, stakeAmount, {from: accounts[1]});
                    await expectRevert(wgcfStake.stake(stakeAmount, root, {from: accounts[1]}), 'WGCF: order not expired');
                });
            });
            context('# stake with root address', () => {
                before('!! deploy setup', async () => {
                    wgcfStake = await WGCF_Stake.new();
                    await wgcfStake.__WGCF_Stake_init(governor, root, lock1, lock2);
                    stakeAmount = toWei(`200`)
                    await wgcfStake.transfer(accounts[1], stakeAmount);
                    await wgcfStake.approve(wgcfStake.address, stakeAmount, {from: accounts[1]});
                });
                it('stake with root address', async () => {
                    let tx = await wgcfStake.stake(stakeAmount, root, {from: accounts[1]});
                    await expectEvent.inTransaction(tx.tx, wgcfStake, 'Staked', {user: accounts[1], amount: stakeAmount.toString()});
                    let father = await wgcfStake.userInfo(root);
                    let son = await wgcfStake.userInfo(accounts[1]);
                    let order = await wgcfStake.stakeOrder(accounts[1]);
                    expect(stakeAmount).to.equal(BigInt(father.levels[0]).toString());
                    expect(root).to.equal(son.father);
                    expect(stakeAmount).to.equal(BigInt(order.amount).toString());
                });
            });
        });
    });

    context('# withdraw', () => {
        context('» generics', () => {
            context('» withdraw parameter is not valid', () => {
                before('initialize contract', async () => {
                    wgcfStake = await WGCF_Stake.new();
                    await wgcfStake.__WGCF_Stake_init(governor, root, lock1, lock2);
                    stakeAmount = toWei(`200`)
                    await wgcfStake.transfer(accounts[1], stakeAmount);
                    await wgcfStake.approve(wgcfStake.address, stakeAmount, {from: accounts[1]});
                    await wgcfStake.stake(stakeAmount, root, {from: accounts[1]});
                });
                it('it reverts: withdraw when not expire', async () => {
                    await expectRevert(wgcfStake.withdraw({from: accounts[1]}), 'WGCF: order not expired');
                });
                it('it reverts: withdraw 0', async () => {
                    await expectRevert(wgcfStake.withdraw({from: accounts[2]}), 'WGCF: cannot withdraw 0');
                });
            });

            context('» withdraw parameter is valid', () =>{
                before('initialize contract', async () => {
                    wgcfStake = await WGCF_Stake.new();
                    await wgcfStake.__WGCF_Stake_init(governor, root, lock1, lock2);
                    stakeAmount = toWei(`200`)
                    await wgcfStake.transfer(accounts[1], stakeAmount);
                    await wgcfStake.approve(wgcfStake.address, stakeAmount, {from: accounts[1]});
                    await wgcfStake.stake(stakeAmount, root, {from: accounts[1]});
                });
                it('withdraws', async () => {
                    await time.increase(time.duration.days(30));
                    let tx = await wgcfStake.withdraw({from: accounts[1]});
                    let destroyAmount = BigInt(stakeAmount) * BigInt(300) / BigInt(10000);
                    await expectEvent.inTransaction(tx.tx, wgcfStake, 'Transfer', {from: wgcfStake.address, to: '0x0000000000000000000000000000000000000001', value: destroyAmount.toString()});
                    await expectEvent.inTransaction(tx.tx, wgcfStake, 'Transfer', {from: wgcfStake.address, to: accounts[1], value: (BigInt(stakeAmount) - destroyAmount).toString()});
                    await expectEvent.inTransaction(tx.tx, wgcfStake, 'Withdrawn', {user: accounts[1], amount: stakeAmount.toString()});
                });
            });
        });
    });

    context('# getReward', () => {
        context('» generics', () => {
            context('» getReward param valid: rewards 0', async () => {
                before('!! fund & initialize contract', async () => {
                    wgcfStake = await WGCF_Stake.new();
                    await wgcfStake.__WGCF_Stake_init(governor, root, lock1, lock2);
                });
                it('rewards 0', async () => {
                    expect((await wgcfStake.earned(accounts[1])).toString()).to.equal(toWei('0'));
                    await wgcfStake.getReward( { from: accounts[1]} );
                    expect((await wgcfStake.earned(accounts[1])).toString()).to.equal(toWei('0'));
                    expect((await wgcfStake.balanceOf(accounts[1])).toString()).to.equal(toWei('0'));
                });
            });
            context('» getReward param valid: rewards', async () => {
                before('!! fund accounts', async () => {
                    wgcfStake = await WGCF_Stake.new();
                    await wgcfStake.__WGCF_Stake_init(governor, root, lock1, lock2);
                    stakeAmount = toWei(`200`)
                    await wgcfStake.transfer(accounts[1], stakeAmount);
                    await wgcfStake.approve(wgcfStake.address, stakeAmount, {from: accounts[1]});
                });
                it('rewards after time period', async () => {
                    /* not staked - no reward earned */
                    expect((await wgcfStake.earned(accounts[1])).toString()).to.equal(toWei('0'));
                    /* stake */
                    await wgcfStake.stake(stakeAmount, root, { from: accounts[1] });
                    /* fast-forward 1 week */
                    await time.increase(time.duration.weeks(1));
                    let earned = BigInt(await wgcfStake.earned(accounts[1]));
                    let tx = await wgcfStake.getReward( { from: accounts[1] } );
                    await expectEvent.inTransaction(tx.tx, wgcfStake, 'RewardPaid', {user: accounts[1], reward: earned.toString()});
                    let balance = BigInt(await wgcfStake.balanceOf(accounts[1]));
                    expect(earned).to.equal(balance);
                });
            });
        });
    });

    context('# checkHalve modifier', () => {
        context('» generics', () => {
            before('!! deploy setup', async () => {
                wgcfStake = await WGCF_Stake.new();
                await wgcfStake.__WGCF_Stake_init(governor, root, lock1, lock2);
                stakeAmount = toWei(`200`);
                await wgcfStake.transfer(accounts[1], toWei(`1400`));
                await wgcfStake.approve(wgcfStake.address, toWei(`1400`), {from: accounts[1]});
            });
            it('halve', async () => {
                let periodFinish1 = BigInt(await wgcfStake.periodFinish());
                let reward1 = BigInt(await wgcfStake.earned(accounts[1]));
                await wgcfStake.getReward( { from: accounts[1]} );
                await wgcfStake.stake(stakeAmount, root, { from: accounts[1] });

                await time.increase(time.duration.years(3));
                let reward2 = BigInt(await wgcfStake.earned(accounts[1]));
                await wgcfStake.getReward( { from: accounts[1]} );
                await wgcfStake.withdraw({ from: accounts[1] });
                await wgcfStake.stake(stakeAmount, root, { from: accounts[1] });
                let periodFinish2 = BigInt(await wgcfStake.periodFinish());

                await time.increase(time.duration.years(3));
                let reward3 = BigInt(await wgcfStake.earned(accounts[1]));
                await wgcfStake.getReward( { from: accounts[1]} );
                await wgcfStake.withdraw({ from: accounts[1] });
                await wgcfStake.stake(stakeAmount, root, { from: accounts[1] });
                let periodFinish3 = BigInt(await wgcfStake.periodFinish());

                await time.increase(time.duration.years(3));
                let reward4 = BigInt(await wgcfStake.earned(accounts[1]));
                await wgcfStake.getReward( { from: accounts[1]} );
                await wgcfStake.withdraw({ from: accounts[1] });
                await wgcfStake.stake(stakeAmount, root, { from: accounts[1] });
                let periodFinish4 = BigInt(await wgcfStake.periodFinish());

                await time.increase(time.duration.years(3));
                let reward5 = BigInt(await wgcfStake.earned(accounts[1]));
                await wgcfStake.getReward( { from: accounts[1]} );
                await wgcfStake.withdraw({ from: accounts[1] });
                await wgcfStake.stake(stakeAmount, root, { from: accounts[1] });
                let periodFinish5 = BigInt(await wgcfStake.periodFinish());

                await time.increase(time.duration.years(3));
                let reward6 = BigInt(await wgcfStake.earned(accounts[1]));
                await wgcfStake.getReward( { from: accounts[1]} );
                await wgcfStake.withdraw({ from: accounts[1] });
                await wgcfStake.stake(stakeAmount, root, { from: accounts[1] });
                let periodFinish6 = BigInt(await wgcfStake.periodFinish());

                await time.increase(time.duration.years(3));
                let reward7 = BigInt(await wgcfStake.earned(accounts[1]));
                await wgcfStake.getReward( { from: accounts[1]} );
                await wgcfStake.withdraw({ from: accounts[1] });
                await wgcfStake.stake(stakeAmount, root, { from: accounts[1] });
                let periodFinish7 = BigInt(await wgcfStake.periodFinish());

                console.log(`${periodFinish1.toString()}:${reward1.toString()}`);
                console.log(`${periodFinish2.toString()}:${reward2.toString()}`);
                console.log(`${periodFinish3.toString()}:${reward3.toString()}`);
                console.log(`${periodFinish4.toString()}:${reward4.toString()}`);
                console.log(`${periodFinish5.toString()}:${reward5.toString()}`);
                console.log(`${periodFinish6.toString()}:${reward6.toString()}`);
                console.log(`${periodFinish7.toString()}:${reward7.toString()}`);
            });
        });
    });

    context('# promotion system', () => {
        context('» generics', () => {
            context('test condition is invalid', async () => {
                before('!! deploy setup', async () => {
                    wgcfStake = await WGCF_Stake.new();
                    await wgcfStake.__WGCF_Stake_init(governor, root, lock1, lock2);
                    stakeAmount = toWei(`200`);
                    for (let index = 1; index < accounts.length; index ++) {
                        await wgcfStake.transfer(accounts[index], stakeAmount);
                        await wgcfStake.approve(wgcfStake.address, stakeAmount, {from: accounts[index]});
                        await wgcfStake.stake(stakeAmount, index === 1 ? root : accounts[index - 1], { from: accounts[index] });
                    }
                });
                it('check promotedAmount', async () => {
                    let userInfo = await wgcfStake.userInfo(root);
                    expect('0').to.equal(BigInt(userInfo.promoted).toString());
                    expect(stakeAmount).to.equal(BigInt(userInfo.levels[0]).toString());
                    expect((BigInt(stakeAmount) * BigInt(2)).toString()).to.equal(BigInt(userInfo.levels[1]).toString());
                    expect((BigInt(stakeAmount) * BigInt(2)).toString()).to.equal(BigInt(userInfo.levels[2]).toString());
                    expect((BigInt(stakeAmount) * BigInt(5)).toString()).to.equal(BigInt(userInfo.levels[3]).toString());
                    expect((BigInt(stakeAmount) * BigInt(5)).toString()).to.equal(BigInt(userInfo.levels[4]).toString());
                });
            });

            context('test condition is valid', async () => {
                before('!! deploy setup', async () => {
                    wgcfStake = await WGCF_Stake.new();
                    await wgcfStake.__WGCF_Stake_init(governor, root, lock1, lock2);
                    stakeAmount = toWei(`200`);

                    await wgcfStake.transfer(accounts[1], toWei(`${100 * 20}`));
                    await wgcfStake.approve(wgcfStake.address, toWei(`${100 * 20}`), {from: accounts[1]});
                    await wgcfStake.stake(toWei(`${100 * 20}`), root, { from: accounts[1] });

                    for (let index = 2; index < accounts.length; index ++) {
                        await wgcfStake.transfer(accounts[index], stakeAmount);
                        await wgcfStake.approve(wgcfStake.address, stakeAmount, {from: accounts[index]});
                        await wgcfStake.stake(stakeAmount, accounts[index - 1], { from: accounts[index] });
                    }
                });
                it('check promotedAmount', async () => {
                    let userInfo = await wgcfStake.userInfo(accounts[1]);
                    expect((BigInt(stakeAmount) / BigInt(10) * BigInt(15)).toString()).to.equal(BigInt(userInfo.promoted).toString());
                    expect(stakeAmount).to.equal(BigInt(userInfo.levels[0]).toString());
                    expect((BigInt(stakeAmount) * BigInt(2)).toString()).to.equal(BigInt(userInfo.levels[1]).toString());
                    expect((BigInt(stakeAmount) * BigInt(2)).toString()).to.equal(BigInt(userInfo.levels[2]).toString());
                    expect((BigInt(stakeAmount) * BigInt(5)).toString()).to.equal(BigInt(userInfo.levels[3]).toString());
                    expect((BigInt(stakeAmount) * BigInt(5)).toString()).to.equal(BigInt(userInfo.levels[4]).toString());
                });
                it('check promotedAmount after withdrawn', async () => {
                    await time.increase(time.duration.days(30));
                    for (let index = 2; index < accounts.length; index ++)
                        await wgcfStake.withdraw({from: accounts[index]});

                    let userInfo = await wgcfStake.userInfo(accounts[1]);
                    expect('0').to.equal(BigInt(userInfo.promoted).toString());
                    for (let index = 0; index < userInfo.levels.length; index ++)
                        expect('0').to.equal(BigInt(userInfo.levels[index]).toString());
                });
                it('check promotedAmount when order expire', async () => {
                    for (let index = 2; index < accounts.length; index ++) {
                        await wgcfStake.transfer(accounts[index], stakeAmount);
                        await wgcfStake.approve(wgcfStake.address, stakeAmount, {from: accounts[index]});
                        await wgcfStake.stake(stakeAmount, accounts[index - 1], { from: accounts[index] });
                    }

                    let userInfo = await wgcfStake.userInfo(accounts[1]);
                    expect('0').to.equal(BigInt(userInfo.promoted).toString());
                    expect((BigInt(stakeAmount) * BigInt(2)).toString()).to.equal(BigInt(userInfo.levels[1]).toString());
                    expect((BigInt(stakeAmount) * BigInt(2)).toString()).to.equal(BigInt(userInfo.levels[2]).toString());
                    expect((BigInt(stakeAmount) * BigInt(5)).toString()).to.equal(BigInt(userInfo.levels[3]).toString());
                    expect((BigInt(stakeAmount) * BigInt(5)).toString()).to.equal(BigInt(userInfo.levels[4]).toString());
                });
            });
        });
    });

    context('# Lock', () => {
        context('» generics', () => {
            before('!! deploy setup', async () => {
                wgcfStake = await WGCF_Stake.new();
                await wgcfStake.__WGCF_Stake_init(governor, root, lock1, lock2);
            });
            it('claim coin', async () => {
                let claimable1 = BigInt(await wgcfStake.checkRelease(lock1));
                let claimable2 = BigInt(await wgcfStake.checkRelease(lock2));
                expect(claimable1.toString()).to.equal('0');
                expect(claimable2.toString()).to.equal('0');

                await time.increase(time.duration.days(6 * 30 - 1));
                claimable1 = BigInt(await wgcfStake.checkRelease(lock1));
                claimable2 = BigInt(await wgcfStake.checkRelease(lock2));
                expect(claimable1.toString()).to.equal('0');
                expect(claimable2.toString()).to.equal('0');

                await expectRevert(wgcfStake.claimCoin({from: lock1}), 'WGCF: can not release 0');
                await expectRevert(wgcfStake.claimCoin({from: lock2}), 'WGCF: can not release 0');

                await time.increase(time.duration.days(1));
                claimable1 = BigInt(await wgcfStake.checkRelease(lock1));
                claimable2 = BigInt(await wgcfStake.checkRelease(lock2));
                expect(claimable1.toString()).to.equal(toWei('60000'));
                expect(claimable2.toString()).to.equal(toWei('40000'));

                await wgcfStake.claimCoin({from: lock1});
                await wgcfStake.claimCoin({from: lock2});

                for (let index = 0; index < 4; index ++) {
                    await time.increase(time.duration.days(30));
                    claimable1 = BigInt(await wgcfStake.checkRelease(lock1));
                    claimable2 = BigInt(await wgcfStake.checkRelease(lock2));
                    expect(claimable1.toString()).to.equal(toWei('60000'));
                    expect(claimable2.toString()).to.equal(toWei('40000'));

                    await wgcfStake.claimCoin({from: lock1});
                    await wgcfStake.claimCoin({from: lock2});
                }

                await time.increase(time.duration.days(60));
                claimable1 = BigInt(await wgcfStake.checkRelease(lock1));
                claimable2 = BigInt(await wgcfStake.checkRelease(lock2));
                expect(claimable1.toString()).to.equal(toWei('0'));
                expect(claimable2.toString()).to.equal(toWei('0'));

                await expectRevert(wgcfStake.claimCoin({from: lock1}), 'WGCF: can not release 0');
                await expectRevert(wgcfStake.claimCoin({from: lock2}), 'WGCF: can not release 0');

                let balance1 = BigInt(await wgcfStake.balanceOf(lock1));
                let balance2 = BigInt(await wgcfStake.balanceOf(lock2));
                expect(balance1.toString()).to.equal(toWei('300000'));
                expect(balance2.toString()).to.equal(toWei('200000'));
            });
        });
    });
});