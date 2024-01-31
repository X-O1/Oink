// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title Oink
 * @author https://github.com/X-O1
 * @notice Oink is an Estate planner for blockchain-based assets.
 * This contract will handle creation of decendant accounts, account funding, and inheritance execution.
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Oink is ReentrancyGuard {
    //ERRORS
    error Oink__MustBeMoreThanZero();
    error Oink__TokenOrAmountNotApprovedForTransfer();
    error Oink__TransferFailed();

    // TYPE DECLARATIONS
    struct Beneficiary {
        address mainAddress;
        address backupAddress;
    }

    // STATE VARIABLESdecedant
    mapping(address => uint256 amount) private s_decedantEtherBalance;
    mapping(address decendant => mapping(address token => uint256 amount)) private s_decedantErc20Balance;
    mapping(address decendant => mapping(address token => uint256 tokenId)) private s_decedantNftBalance;

    mapping(address beneficiary => uint256 amount) private s_beneficiaryEtherAllocation;
    mapping(address beneficiary => mapping(address token => uint256 amount)) private s_beneficiaryErc20Allocation;
    mapping(address beneficiary => mapping(address nft => uint256 tokenId)) private s_beneficiaryNftAllocation;

    // EVENTS
    event TokenDeposited(address indexed decendant, address indexed beneficiary, address indexed token, uint256 amount);
    event NftDeposited(address indexed decendant, address indexed beneficiary, address indexed nft, uint256 tokenId);
    event EtherDeposited(address indexed decendant, address indexed beneficiary, uint256 indexed amount);

    // MODIFIERS
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert Oink__MustBeMoreThanZero();
        }
        _;
    }

    // FUNCTIONS
    function depositEther(address beneficiary, uint256 amount) external payable moreThanZero(amount) nonReentrant {
        s_decedantEtherBalance[msg.sender] += amount;
        s_beneficiaryEtherAllocation[beneficiary] += amount;
        emit EtherDeposited(msg.sender, beneficiary, amount);
    }

    function depositErc20(address beneficiary, address token, uint256 amount)
        external
        moreThanZero(amount)
        nonReentrant
    {
        s_decedantErc20Balance[msg.sender][token] += amount;
        s_beneficiaryErc20Allocation[beneficiary][token] += amount;
        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        if (!success) {
            revert Oink__TransferFailed();
        }
        emit TokenDeposited(msg.sender, beneficiary, token, amount);
    }

    function depositNft(address beneficiary, address token, uint256 tokenId)
        external
        moreThanZero(tokenId)
        nonReentrant
    {
        s_decedantNftBalance[msg.sender][token] += tokenId;
        s_beneficiaryNftAllocation[beneficiary][token] += tokenId;

        IERC721(token).transferFrom(msg.sender, address(this), tokenId);
        emit NftDeposited(msg.sender, beneficiary, token, tokenId);
    }

    // VIEW FUNCTIONS
    function getDecendantEtherBalance(address decendant) external view returns (uint256 amount) {
        return s_decedantEtherBalance[decendant];
    }

    function getDecendantErc20Balance(address decendant, address token) external view returns (uint256 amount) {
        return s_decedantErc20Balance[decendant][token];
    }

    function getDecendantNftBalance(address decendant, address token) external view returns (uint256 tokenId) {
        return s_decedantNftBalance[decendant][token];
    }

    function getBeneficiaryEtherAllocation(address beneficiary) external view returns (uint256 amount) {
        return s_beneficiaryEtherAllocation[beneficiary];
    }

    function getBeneficiaryErc20Allocation(address beneficiary, address token) external view returns (uint256 amount) {
        return s_beneficiaryErc20Allocation[beneficiary][token];
    }

    function getBeneficiaryNftAllocation(address beneficiary, address token) external view returns (uint256 tokenId) {
        return s_beneficiaryNftAllocation[beneficiary][token];
    }
}
