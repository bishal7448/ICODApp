// SPDX-License-Identifier: MIT 
pragma solidity >=0.5.0 <0.9.0;

// Architecture and Structure:
/**
 * @title TokenICO
 * @dev A gas-efficient ERC20 token ICO contract for token sales.
 * 
 * Features:
 * - Configurable token price
 * - Proper handling of token decimals
 * - Direct ETH transfer to the owner
 * - Gas optimization for mainnet deployment
 * - Token rescue functionality
 * - Protection against direct ETH transfers
 * 
 * This contract has been audited and gas efficient
 * Last updated: July 2025
 * Author: Bishal Saha
 * Version: 1.0.0
 */

interface ERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8); // Fee for gas optimization
}

contract TokenICO {
    // State variables
    address public immutable owner;
    address public saleToken; // Address of the token being sold
    uint256 public ethPriceForToken = 0.001 ether;
    uint256 public tokensSold;

    // Events
    event TokenPurchased(address indexed _buyer, uint256 _amountPaid, uint256 _tokensBought);
    event PriceUpdated(uint256 _oldPrice, uint256 _newPrice);
    event SaleTokenSet(address indexed _tokenAddress); // Set the token in contract

    // Custom errors for gas efficiency
    error OnlyOwner();
    error InvalidPrice();
    error InvalidAddress();
    error NoETHSent();
    error SaleTokenNotSet();
    error TokenTransferFailed();
    error ETHTransferFailed();
    error NoTokensToWithdraw();
    error CannotRescueSaleToken();
    error NoTokensToRescue();
    error UseTokenFunction();

    constructor() {
        owner = msg.sender; // Set the contract deployer as the owner
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert OnlyOwner();
        }
        _;
    }

    // Prevent direct ETH transfers
    receive() external payable {
        revert UseTokenFunction();
    }

    // Admin functions
    function updateTokenPrice(uint256 _newPrice) external onlyOwner {
        if(_newPrice == 0) {
            revert InvalidPrice();
        }
        uint256 oldPrice = ethPriceForToken;
        ethPriceForToken = _newPrice;
        emit PriceUpdated(oldPrice, ethPriceForToken);
    }

    function setSaleToken(address _tokenAddress) external onlyOwner {
        if( _tokenAddress == address(0)) {
            revert InvalidAddress();
        }
        saleToken = _tokenAddress;
        emit SaleTokenSet(_tokenAddress);
    }

    function withdrawAllTokens() external onlyOwner {
        address tokenAddress = saleToken;
        uint256 balance = ERC20(tokenAddress).balanceOf(address(this));
        if (balance == 0) {
            revert NoTokensToWithdraw();
        }
        if(!ERC20(tokenAddress).transfer(owner, balance)) {
            revert TokenTransferFailed();
        }
    }

    // User functions
    function buyTokens() external payable {
        if(msg.value == 0) {
            revert NoETHSent();
        }

        address tokenAddress = saleToken;
        if (tokenAddress == address(0)) {
            revert SaleTokenNotSet();
        }

        // Calculate token ammount according to token decimals
        ERC20 tokenContract = ERC20(tokenAddress);
        uint8 decimals = tokenContract.decimals();
        uint256 tokenAmount = (msg.value * (10 ** decimals)) / ethPriceForToken;

        // Process token purchase
        unchecked {
            tokensSold += tokenAmount;
        }

        // Token transfer
        if(!tokenContract.transfer(msg.sender, tokenAmount)) {
            revert TokenTransferFailed();
        }

        // ETH transfer to owner
        (bool success, ) = owner.call{value: msg.value}("");
        if (!success) {
            revert ETHTransferFailed();
        }

        emit TokenPurchased(msg.sender, msg.value, tokenAmount);
    }

    function rescueTokens(address _tokenAddress) external onlyOwner {
        if (_tokenAddress == saleToken) {
            revert CannotRescueSaleToken();
        }

        ERC20 tokenContract = ERC20(_tokenAddress);
        uint256 balance = tokenContract.balanceOf(address(this));

        if (balance == 0) {
            revert NoTokensToRescue();
        }

        if (!tokenContract.transfer(owner, balance)) {
            revert TokenTransferFailed();
        }
    } 

    // View functions
    function getContractInfo() external view returns(
        address tokenAddress,
        string memory tokenSymbol,
        uint8 tokenDecimals,
        uint256 tokenPrice,
        uint256 ethPrice,
        uint256 totalTokensSold
    ) {

        address token = saleToken;
        ERC20 tokenContract = ERC20(token);

        return (
            token,
            tokenContract.symbol(),
            tokenContract.decimals(),
            tokenContract.balanceOf(address(this)),
            ethPriceForToken,
            tokensSold
        );
    }

}
