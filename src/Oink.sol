// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title Oink
 * @author https://github.com/X-O1
 * @notice Oink is an Estate planner for blockchain-based assets.
 * This contract will handle creation of user accounts, account funding, and inheritance execution.
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

    // STATE VARIABLES
    mapping(address user => uint256 amount) private s_userEtherBalance;
    mapping(address user => mapping(address token => uint256 amount)) private s_userTokenBalance;
    mapping(address user => mapping(address token => uint256 tokenId)) private s_userNftBalance;

    // EVENTS
    event TokenDeposited(address indexed user, address indexed token, uint256 indexed amount);
    event NftDeposited(address indexed user, address indexed nft, uint256 indexed tokenId);
    event EtherDeposited(address indexed user, uint256 indexed amount);

    // MODIFIERS
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert Oink__MustBeMoreThanZero();
        }
        _;
    }

    // FUNCTIONS
    function depositEther(uint256 amount) external payable moreThanZero(amount) nonReentrant {
        s_userEtherBalance[msg.sender] += amount;
        emit EtherDeposited(msg.sender, amount);
    }

    function depositToken(address token, uint256 amount) external moreThanZero(amount) nonReentrant {
        s_userTokenBalance[msg.sender][token] += amount;
        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        if (!success) {
            revert Oink__TransferFailed();
        }
        emit TokenDeposited(msg.sender, token, amount);
    }

    function depositNft(address nft, uint256 tokenId) external moreThanZero(tokenId) nonReentrant {
        s_userNftBalance[msg.sender][nft] += tokenId;
        IERC721(nft).transferFrom(msg.sender, address(this), tokenId);
        emit NftDeposited(msg.sender, nft, tokenId);
    }
}
