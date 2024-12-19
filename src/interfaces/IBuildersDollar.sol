// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IPool} from './IPool.sol';
import {IRewardsController} from './IRewardsController.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

/**
 * @title BuildersDollar Contract
 * @author Breadchain
 * @notice This contract manages BuildersDollar
 */
interface IBuildersDollar {
  /*///////////////////////////////////////////////////////////////
                            DATA
    //////////////////////////////////////////////////////////////*/

  /*///////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/
  /**
   * @notice Emitted when tokens are minted
   * @param _receiver The address of the receiver
   * @param _amount The amount minted
   */
  event Minted(address _receiver, uint256 _amount);

  /**
   * @notice Emitted when tokens are burned
   * @param _receiver The address of the receiver
   * @param _amount The amount burned
   */
  event Burned(address _receiver, uint256 _amount);

  /**
   * @notice Emitted when yieldClaimer is set
   * @param _yieldClaimer The address of the yield claimer
   */
  event YieldClaimerSet(address _yieldClaimer);

  /**
   * @notice Emitted when yield is claimed
   * @param _amount The amount of yield claimed
   */
  event ClaimedYield(uint256 _amount);

  /**
   * @notice Emitted when rewards are claimed
   * @param _rewardsList A list of the reward's addresses
   * @param _claimedAmounts A list of the amounts claimed
   */
  event ClaimedRewards(address[] _rewardsList, uint256[] _claimedAmounts);

  /*///////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/

  /// @notice Throws when the value is zero
  error ZeroValue();
  /// @notice Throws when the amount of minted tokens is wrong
  error WrongMintingValue();
  /// @notice Throws when the amount of burned tokens is wrong
  error WrongBurningValue();
  /// @notice Throws when the amount of yield is wrong
  error WrongClaimValue();
  /// @notice Throws when the yield is less that the amount requested to claim
  error YieldInsufficient();
  /// @notice Throws when the internal claimRewards function failed to run
  error ClaimRewardsFailed();
  /// @notice Throws when the collateral tried to be saved
  error UCantTouchThis();

  /*///////////////////////////////////////////////////////////////
                            LOGIC
    //////////////////////////////////////////////////////////////*/
  /**
   * @notice Initialize the BuildersToken contract
   * @param _name The name of the token
   * @param _symbol The symbol of the token
   */
  function initialize(string memory _name, string memory _symbol) external;

  /**
   * @notice Set the yield claimer
   * @param _yieldClaimer The Address of the yield claimer
   */
  function setYieldClaimer(address _yieldClaimer) external;

  /**
   * @notice Mint the base token
   * @param _amount The amount to be minted
   * @param _receiver The address of the receiver
   */
  function mint(uint256 _amount, address _receiver) external;

  /**
   * @notice Burn the base token
   * @param _amount The amount to be burned
   * @param _receiver The address of the receiver
   */
  function burn(uint256 _amount, address _receiver) external;

  /**
   * @notice Claim yield
   * @dev Access Control: onlyYieldClaimer
   * @param _amount The amount of yield to be claimed
   */
  function claimYield(uint256 _amount) external;

  /**
   * @notice Rescue tokens
   * @dev Access Control: onlyOwner
   * @param _token The address of the token to be rescued
   * @param _amount The amount of the token to be rescued
   */
  function rescueToken(address _token, uint256 _amount) external;

  /*///////////////////////////////////////////////////////////////
                            VIEW
    //////////////////////////////////////////////////////////////*/
  /**
   * @notice Get the base Token
   * @dev This variable is immutable and set during intialization
   * @return _baseToken The base Token
   */
  // solhint-disable-next-line func-name-mixedcase
  function BASE_TOKEN() external view returns (IERC20 _baseToken);

  /**
   * @notice Get the interest bearing token
   * @dev This variable is immutable and set during intialization
   * @return _interestBearingToken The interest bearing token
   */
  // solhint-disable-next-line func-name-mixedcase
  function INTEREST_BEARING_TOKEN() external view returns (IERC20 _interestBearingToken);

  /**
   * @notice Get the pool interface of the payment distibutor
   * @dev This variable is immutable and set during intialization
   * @return _paymentDistributor The pool interface of the payment distributor (probably a pool address).
   */
  // solhint-disable-next-line func-name-mixedcase
  function PAYMENT_DISTRIBUTOR() external view returns (IPool _paymentDistributor);

  /**
   * @notice Set the rewards interface
   * @dev This variable is immutable and set during intialization
   * @return _rewards The rewards interface.
   */
  // solhint-disable-next-line func-name-mixedcase
  function REWARDS() external view returns (IRewardsController _rewards);

  /**
   * @notice Get the address of the yield claimer
   * @return _yieldClaimer The address of the yield claimer
   */
  // solhint-disable-next-line func-name-mixedcase
  function YIELD_CLAIMER() external view returns (address _yieldClaimer);

  /**
   * @notice Check the amount of yield accrued
   * @return _amount The amount of yield accrued
   */
  function yieldAccrued() external view returns (uint256 _amount);

  /**
   * @notice Check the amount of rewards accrued
   * @return _rewardsList The list of rewards addresses
   * @return _unclaimedAmounts The list of amounts of rewards accrued
   */
  function rewardsAccrued() external view returns (address[] memory _rewardsList, uint256[] memory _unclaimedAmounts);
}
