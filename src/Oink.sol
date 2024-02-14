// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Oink!
 * @author https://github.com/X-O1
 * @notice Smart contract-based savings account with trustless inheritance execution.
 *
 * This contract manages user and beneficiary accounts and inheritance execution.
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Oink is ReentrancyGuard {
    //ERRORS
    error Oink__MustBeMoreThanZero();
    error Oink__TransferFailed();
    error Oink__NotBeneficiary();

    // TYPE DECLARATIONS
    struct Beneficiary {
        address mainAddress;
        address backupAddress;
    }

    // STATE VARIABLES
    mapping(address user => uint256 amount) private s_etherBalance;
    mapping(address user => mapping(address token => uint256 amount)) private s_erc20Balance;
    mapping(address user => address[] beneficiaries) private s_beneficiaries;

    // EVENTS
    event EtherDeposited(address indexed user, uint256 indexed amount);
    event Erc20Deposited(address indexed user, address indexed token, uint256 indexed amount);
    event EtherWithdrawl(address indexed user, uint256 indexed amount);
    event Erc20Withdrawl(address indexed user, address indexed token, uint256 indexed amount);
    event EtherInherited(address indexed user, uint256 indexed amount);
    event Erc20Inherited(address indexed user, address indexed token, uint256 indexed _mount);
    event BeneficiaryAdded(address indexed user, address indexed beneficiary);

    // MODIFIERS
    modifier moreThanZero(uint256 _amount) {
        if (_amount == 0) {
            revert Oink__MustBeMoreThanZero();
        }
        _;
    }

    modifier onlyBeneficiary(address _decendant) {
        for (uint256 i = 0; i < s_beneficiaries[_decendant].length; i++) {
            if (s_beneficiaries[_decendant][i] == msg.sender) {
                _;
                return;
            }
        }
        revert Oink__NotBeneficiary();
    }

    // FUNCTIONS

    receive() external payable {}

    function depositEther() external payable moreThanZero(msg.value) {
        s_etherBalance[msg.sender] += msg.value;
        emit EtherDeposited(msg.sender, msg.value);
    }

    function withdrawEther(uint256 _amount) external moreThanZero(_amount) nonReentrant {
        require(s_etherBalance[msg.sender] >= _amount, "Insufficient Funds");

        s_etherBalance[msg.sender] -= _amount;

        (bool success,) = payable(msg.sender).call{value: _amount}("");
        if (!success) {
            revert Oink__TransferFailed();
        }

        emit EtherWithdrawl(msg.sender, _amount);
    }

    function inheritEther(address _decendant, uint256 _amount) external onlyBeneficiary(_decendant) nonReentrant {
        require(s_etherBalance[_decendant] >= _amount, "Insufficient Funds");
        s_etherBalance[_decendant] -= _amount;

        (bool success,) = msg.sender.call{value: _amount}("");
        if (!success) {
            revert Oink__TransferFailed();
        }

        emit EtherInherited(msg.sender, _amount);
    }

    function depositErc20(address _token, uint256 _amount) external moreThanZero(_amount) {
        s_erc20Balance[msg.sender][_token] += _amount;

        require(IERC20(_token).allowance(msg.sender, address(this)) >= _amount, "Amount not approved for transfer");

        bool success = IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        if (!success) {
            revert Oink__TransferFailed();
        }
        emit Erc20Deposited(msg.sender, _token, _amount);
    }

    function withdrawErc20(address _token, uint256 _amount) external moreThanZero(_amount) nonReentrant {
        require(s_erc20Balance[msg.sender][_token] >= _amount, "Insufficient Funds");

        s_erc20Balance[msg.sender][_token] -= _amount;
        bool success = IERC20(_token).transfer(msg.sender, _amount);
        if (!success) {
            revert Oink__TransferFailed();
        }

        emit Erc20Withdrawl(msg.sender, _token, _amount);
    }

    function inheritErc20(address _decendant, address _token, uint256 _amount)
        external
        onlyBeneficiary(_decendant)
        nonReentrant
    {
        require(s_erc20Balance[_decendant][_token] >= _amount, "Insufficient Funds");

        s_erc20Balance[_decendant][_token] -= _amount;

        bool success = IERC20(_token).transfer(msg.sender, _amount);
        if (!success) {
            revert Oink__TransferFailed();
        }

        emit Erc20Inherited(msg.sender, _token, _amount);
    }

    function addBeneficiary(address beneficiary) external {
        s_beneficiaries[msg.sender].push(beneficiary);
        emit BeneficiaryAdded(msg.sender, beneficiary);
    }

    // VIEW FUNCTIONS
    function getEtherBalance(address user) external view returns (uint256 _amount) {
        return s_etherBalance[user];
    }

    function getErc20Balance(address user, address _token) external view returns (uint256 _amount) {
        return s_erc20Balance[user][_token];
    }

    function getListOfBeneficiaries(address user) external view returns (address[] memory beneficiaries) {
        return s_beneficiaries[user];
    }
}
