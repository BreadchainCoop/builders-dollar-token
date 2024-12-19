// SPDX-License-Identifier: PPL
pragma solidity 0.8.23;

import {Ownable2StepUpgradeable} from '@oz-upgradeable/access/Ownable2StepUpgradeable.sol';
import {ERC20Upgradeable} from '@oz-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import {IERC20} from '@oz/token/ERC20/IERC20.sol';
import {SafeERC20} from '@oz/token/ERC20/utils/SafeERC20.sol';
import {IBuildersDollar} from 'interfaces/IBuildersDollar.sol';
import {IPool} from 'interfaces/IPool.sol';
import {IRewardsController} from 'interfaces/IRewardsController.sol';

contract BuildersDollar is ERC20Upgradeable, Ownable2StepUpgradeable, IBuildersDollar {
  using SafeERC20 for IERC20;

  // --- Registry ---

  /// @inheritdoc IBuildersDollar
  // solhint-disable-next-line
  IERC20 public immutable BASE_TOKEN;
  /// @inheritdoc IBuildersDollar
  // solhint-disable-next-line
  IERC20 public immutable INTEREST_BEARING_TOKEN;
  /// @inheritdoc IBuildersDollar
  // solhint-disable-next-line
  IPool public immutable PAYMENT_DISTRIBUTOR;
  /// @inheritdoc IBuildersDollar
  // solhint-disable-next-line
  IRewardsController public immutable REWARDS;
  /// @inheritdoc IBuildersDollar
  // solhint-disable-next-line
  address public YIELD_CLAIMER;

  // --- Modifiers ---

  /**
   * @notice Modifier to check the the sender address is the same as the YIELD_CLAIMER address
   */
  modifier onlyYieldClaimer() {
    _checkYieldClaimer();
    _;
  }

  // --- Initializer ---

  /// @inheritdoc IBuildersDollar
  function initialize(string memory name_, string memory symbol_) external initializer {
    __ERC20_init(name_, symbol_);
    __Ownable2Step_init();
  }

  // --- External Methods ---

  /// @inheritdoc IBuildersDollar
  function setYieldClaimer(address _yieldClaimer) external onlyOwner {
    YIELD_CLAIMER = _yieldClaimer;
    emit YieldClaimerSet(_yieldClaimer);
  }

  /// @inheritdoc IBuildersDollar
  function mint(uint256 _amount, address _receiver) external {
    if (_amount <= 0) revert WrongMintingValue();
    BASE_TOKEN.safeTransferFrom(msg.sender, address(this), _amount);
    BASE_TOKEN.safeIncreaseAllowance(address(PAYMENT_DISTRIBUTOR), _amount);
    PAYMENT_DISTRIBUTOR.supply(address(BASE_TOKEN), _amount, address(this), 0);
    _mint(_receiver, _amount);
    emit Minted(_receiver, _amount);
  }

  /// @inheritdoc IBuildersDollar
  function burn(uint256 _amount, address _receiver) external {
    if (_amount <= 0) revert WrongBurningValue();
    _burn(msg.sender, _amount);
    INTEREST_BEARING_TOKEN.safeIncreaseAllowance(address(PAYMENT_DISTRIBUTOR), _amount);
    PAYMENT_DISTRIBUTOR.withdraw(address(BASE_TOKEN), _amount, _receiver);
    emit Burned(_receiver, _amount);
  }

  /// @inheritdoc IBuildersDollar
  function claimYield(uint256 _amount) external onlyYieldClaimer {
    if (_amount <= 0) revert WrongClaimValue();
    uint256 _yield = _yieldAccrued();
    if (_yield < _amount) revert YieldInsufficient();
    PAYMENT_DISTRIBUTOR.withdraw(address(BASE_TOKEN), _amount, owner());
    emit ClaimedYield(_amount);

    _claimRewards();
  }

  /// @inheritdoc IBuildersDollar
  function rescueToken(address _token, uint256 _amount) external onlyOwner {
    if (_token == address(INTEREST_BEARING_TOKEN)) revert UCantTouchThis();
    IERC20(_token).safeTransfer(owner(), _amount);
  }

  /// @inheritdoc IBuildersDollar
  function yieldAccrued() external view returns (uint256 _amount) {
    return _yieldAccrued();
  }

  /// @inheritdoc IBuildersDollar
  function rewardsAccrued() external view returns (address[] memory rewardsList, uint256[] memory unclaimedAmounts) {
    address[] memory assets;
    assets[0] = address(INTEREST_BEARING_TOKEN);
    return REWARDS.getAllUserRewards(assets, address(this));
  }

  // --- Internal Utilities ---

  /**
   * @notice Internal function to claim the rewards accrued. Called by the external claimYield function
   */
  function _claimRewards() internal {
    address[] memory _assets;
    _assets[0] = address(INTEREST_BEARING_TOKEN);
    try REWARDS.claimAllRewards(_assets, owner()) returns (
      address[] memory _rewardsList, uint256[] memory _claimedAmounts
    ) {
      emit ClaimedRewards(_rewardsList, _claimedAmounts);
    } catch Error(string memory) {
      revert ClaimRewardsFailed();
    }
  }

  /**
   * @notice Internal function to check the yield accrued
   * @return _yield The yield of the INTEREST_BEARING_TOKEN accrued
   */
  function _yieldAccrued() internal view returns (uint256 _yield) {
    return INTEREST_BEARING_TOKEN.balanceOf(address(this)) - totalSupply();
  }

  /**
   * @notice Internal function to check if the message sender is the same with the YIELD_CLAIMER
   */
  function _checkYieldClaimer() internal view virtual {
    if (YIELD_CLAIMER != msg.sender) {
      revert OwnableUnauthorizedAccount(msg.sender);
    }
  }
}
