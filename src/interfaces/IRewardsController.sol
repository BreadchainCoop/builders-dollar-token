// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title RewardsController
 * @author @Astodialo
 * @notice claims rewards from the rewards controller, reference here https://github.com/aave/aave-v3-periphery/blob/master/contracts/rewards/interfaces/IRewardsController.sol
 */
interface IRewardsController {
  /*///////////////////////////////////////////////////////////////
                            LOGIC
    //////////////////////////////////////////////////////////////*/
  /**
   * @notice Claim the rewards
   * @param _assets The list of the assets addresses
   * @param _to The address of the receiver
   * @return  _rewardsList The list of the rewards addresses
   * @return  _claimedAmounts The list of the rewards amounts
   */
  function claimAllRewards(
    address[] calldata _assets,
    address _to
  ) external returns (address[] memory _rewardsList, uint256[] memory _claimedAmounts);

  /*///////////////////////////////////////////////////////////////
                            VIEW
    //////////////////////////////////////////////////////////////*/
  /**
   * @notice Check the amount of rewards accrued
   * @param _assets The list of the assets addresses
   * @param _user The address of the user
   * @return  _rewardsList The list of the rewards addresses
   * @return  _unclaimedAmounts The list of the rewards amounts
   */
  function getAllUserRewards(
    address[] calldata _assets,
    address _user
  ) external view returns (address[] memory _rewardsList, uint256[] memory _unclaimedAmounts);
}
