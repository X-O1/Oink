// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract OinkCoin is ERC20 {
    constructor() ERC20("Oink", "OINK") {
        _mint(0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D, 1000);
    }
}

contract OinkNft is ERC721 {
    constructor() ERC721("OinkNft", "OINKNFT") {
        _safeMint(0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D, 1);
    }
}
