// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title Oink!
 * @author https://github.com/X-O1
 * @notice Smart contract-based digital asset savings account with time locks and trustless inheritance execution.
 * Features:
 * - Savings Account with custom time locks ("Goal Locks"): Account balance is only available for withdrawal after reaching the user-set target.
 * - Add beneficiaries and enable trustless inheritance execution for all accounts.
 *
 * This contract manages user and beneficiary accounts, and inheritance execution.
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
    error Oink__NotBeneficiary();

    // TYPE DECLARATIONS
    struct Beneficiary {
        address mainAddress;
        address backupAddress;
    }

    // STATE VARIABLES
    mapping(address => uint256 amount) private s_etherBalance;
    mapping(address user => mapping(address token => uint256 amount)) private s_erc20Balance;
    mapping(address user => mapping(address token => uint256 tokenId)) private s_nftBalance;
    mapping(address user => address[] beneficiaries) private s_beneficiaries;

    // mapping(address beneficiary => string letter) private s_letterToBeneficiary;

    // EVENTS
    event EtherDeposited(address indexed user, uint256 indexed amount);
    event Erc20Deposited(address indexed user, address indexed token, uint256 indexed amount);
    event NftDeposited(address indexed user, address indexed nft, uint256 indexed tokenId);
    event BeneficiaryAdded(address indexed user, address indexed beneficiary);

    // MODIFIERS
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert Oink__MustBeMoreThanZero();
        }
        _;
    }

    modifier onlyBeneficiary(address decendant, address beneficiary) {
        for (uint256 i = 0; i < s_beneficiaries[decendant].length; i++) {
            if (s_beneficiaries[decendant][i] != msg.sender) {
                revert Oink__NotBeneficiary();
            }
        }
        _;
    }

    // FUNCTIONS
    function depositEther(uint256 amount) public payable moreThanZero(amount) nonReentrant {
        s_etherBalance[msg.sender] += amount;
        emit EtherDeposited(msg.sender, amount);
    }

    function depositErc20(address token, uint256 amount) public moreThanZero(amount) nonReentrant {
        s_erc20Balance[msg.sender][token] += amount;
        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        if (!success) {
            revert Oink__TransferFailed();
        }
        emit Erc20Deposited(msg.sender, token, amount);
    }

    function depositNft(address token, uint256 tokenId) public moreThanZero(tokenId) nonReentrant {
        s_nftBalance[msg.sender][token] += tokenId;
        IERC721(token).transferFrom(msg.sender, address(this), tokenId);
        emit NftDeposited(msg.sender, token, tokenId);
    }

    function withdrawEther(uint256 amount) external moreThanZero(amount) {}
    function withdrawErc20(address token, uint256 amount) external moreThanZero(amount) {}
    function withdrawNft(address token, uint256 tokenId) external moreThanZero(tokenId) {}

    function inheritEther(address decendant) external onlyBeneficiary(decendant, msg.sender) {}
    function inheritErc20(address decendant) external onlyBeneficiary(decendant, msg.sender) {}
    function inheritNft(address decendant) external onlyBeneficiary(decendant, msg.sender) {}

    function addBeneficiary(address beneficiary) public {
        s_beneficiaries[msg.sender].push(beneficiary);
        emit BeneficiaryAdded(msg.sender, beneficiary);
    }

    // function writeLetterToBeneficiary(address beneficiary, string memory letter) external {
    //     s_letterToBeneficiary[beneficiary] = letter;
    // }

    // VIEW FUNCTIONS
    function getEtherBalance(address user) external view returns (uint256 amount) {
        return s_etherBalance[user];
    }

    function getErc20Balance(address user, address token) external view returns (uint256 amount) {
        return s_erc20Balance[user][token];
    }

    function getNftBalance(address user, address token) external view returns (uint256 tokenId) {
        return s_nftBalance[user][token];
    }

    function getListOfBeneficiaries(address user) external view returns (address[] memory beneficiaries) {
        return s_beneficiaries[user];
    }

    // function getLetter(address beneficiary) external view onlyBeneficiary(beneficiary) returns (string memory letter) {
    //     return s_letterToBeneficiary[beneficiary];
    // }
}
