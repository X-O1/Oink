// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract OinkCoin is ERC20 {
    constructor() ERC20("Oink", "OINK") {
        _mint(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 1000);
    }
}

contract OinkNft is ERC721 {
    constructor() ERC721("OinkNft", "OINKNFT") {
        _safeMint(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 1);
    }
}
