// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IMissionDAONFT.sol";
import "../utils/MultiWhitelist.sol";

contract MissionDAOSale is MultiWhitelist {
    using Address for address;
    using SafeMath for uint256;
    IERC20 public TOKEN;
    IMissionDAONFT public NFT;
    bool public isEnabled;
    enum NFTType {
        GENESIS
    }
    mapping(NFTType => string) private _placeholderURIs;
    mapping(NFTType => uint256) public prices;
    mapping(NFTType => uint256) public typeCounter;
    mapping(NFTType => uint256) public typeMax;

    event Sold(uint256 _nftId, address _buyer, uint256 _price);

    constructor(
        address _nftAddress,
        address _tokenAddress,
        uint256[] memory _prices,
        string[] memory placeholderURIs,
        uint256 _purchaseLimit
    ) {
        require(_nftAddress.isContract(), "_nftAddress must be a contract");
        require(_tokenAddress.isContract(), "_tokenAddress must be a contract");
        require(placeholderURIs.length == 1, "Invalid placeholder URI count");
        require(_prices.length == 1, "Invalid prices count");
        // NFT + FT Address
        NFT = IMissionDAONFT(_nftAddress);
        TOKEN = IERC20(_tokenAddress);
        // PRICES
        prices[NFTType.GENESIS] = _prices[0];
        // PLACEHOLDER
        _placeholderURIs[NFTType.GENESIS] = placeholderURIs[0];
        // GENESIS
        typeCounter[NFTType.GENESIS] = 1;
        typeMax[NFTType.GENESIS] = 50;

        // PURCHASE LIMIT PER WALLET
        purchaseLimit = _purchaseLimit;
    }

    /**
     * @notice - Enable/Disable Sales
     * @dev - callable only by owner
     *
     * @param _isEnabled - enable? sales
     */
    function setEnabled(bool _isEnabled) public onlyOwner {
        isEnabled = _isEnabled;
    }

    /**
     * @notice - Set Placeholder URI
     * @dev - callable only by owner
     *
     * @param nftType - Type of NFT
     * @param placeholderURI - Placeholder URI for type of NFT
     */
    function setPlaceholderURI(NFTType nftType, string memory placeholderURI)
    public
    onlyOwner
    {
        _placeholderURIs[nftType] = placeholderURI;
    }

    /**
     * @notice - Set Placeholder URI
     * @dev - callable only by owner
     *
     * @param nftType - Type of NFT
     * @param price - Price of NFT
     */
    function setPrice(NFTType nftType, uint256 price) public onlyOwner {
        prices[nftType] = price;
    }

    /**
     * Purchase NFT
     *
     * @param nftType - Type of NFT
     */
    function purchase(NFTType nftType)
    public
    onlyLimited
    onlyDuringSale
    onlyWhitelisted
    {
        uint256 price = prices[nftType];
        require(
            TOKEN.allowance(_msgSender(), address(this)) >= price,
            "Grant token approval to Sale Contract"
        );
        require(typeCounter[nftType] <= typeMax[nftType], "Sold out");
        address buyer = _msgSender();
        string memory URI = _placeholderURIs[nftType];
        uint256 nftId = typeCounter[nftType];

        TOKEN.transferFrom(buyer, address(this), price);
        NFT.mint(msg.sender, nftId, URI);

        typeCounter[nftType] = typeCounter[nftType].add(1);

        userPurchaseCounter[msg.sender] = userPurchaseCounter[msg.sender].add(
            1
        );

        emit Sold(nftId, buyer, price);
    }

    /**
     * Purchase Batch of NFTs
     *
     * @param nftTypes - List of NFT Types
     */
    function batchPurchase(NFTType[] memory nftTypes)
    external
    onlyLimited
    onlyDuringSale
    onlyWhitelisted
    {
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < nftTypes.length; i++) {
            uint256 price = prices[nftTypes[i]];
            totalAmount = totalAmount.add(price);
        }
        require(
            TOKEN.allowance(_msgSender(), address(this)) >= totalAmount,
            "Grant token approval to Sale Contract"
        );
        for (uint256 i = 0; i < nftTypes.length; i++) {
            purchase(nftTypes[i]);
        }
    }

    /**
     * Withdraw any ERC20
     *
     * @param tokenAddress - ERC20 token address
     * @param amount - amount to withdraw
     * @param wallet - address to withdraw to
     */
    function withdrawFunds(
        address tokenAddress,
        uint256 amount,
        address wallet
    ) external onlyOwner {
        IERC20(tokenAddress).transfer(wallet, amount);
    }

    modifier onlyDuringSale() {
        require(isEnabled, "Sale is not enabled");
        _;
    }
}