// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LINKTUM is ERC20 {
    uint256 private constant INITIAL_SUPPLY = 10_000_000_000; // 10 million tokens

    constructor() ERC20("LINKTUM", "LTUM") {
        _mint(msg.sender, INITIAL_SUPPLY * (10 ** decimals())); // Mint initial supply to the contract deployer
    }
}
