// SPDX-License-Identifier: PPL
pragma solidity 0.8.23;

import {Ownable2StepUpgradeable} from '@oz-upgradeable/access/Ownable2StepUpgradeable.sol';
import {ERC20Upgradeable} from '@oz-upgradeable/token/ERC20/ERC20Upgradeable.sol';
import {IERC20} from '@oz/token/ERC20/IERC20.sol';
import {SafeERC20} from '@oz/token/ERC20/utils/SafeERC20.sol';

contract BuildersDollar is ERC20Upgradeable, Ownable2StepUpgradeable {
  using SafeERC20 for IERC20;

  // --- Registry ---
  IERC20 public immutable BASE_TOKEN;
  IERC20 public immutable INTEREST_BEARING_TOKEN;
  address public immutable PAYMENT_DISTRIBUTOR;

  function initialize(string memory name_, string memory symbol_) public initializer {
    __ERC20_init(name_, symbol_);
    __Ownable2Step_init();
  }
}
