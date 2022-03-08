// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;
pragma abicoder v2;

import "./AccessProtected.sol";

abstract contract MultiWhitelist is AccessProtected {
    mapping(address => Whitelist) private _whitelisted;
    WhitelistType public activeWhitelistType;
    bool public isOpenForAll;
    mapping(address => uint256) public userPurchaseCounter;
    uint256 public purchaseLimit;

    enum WhitelistType {
        PRIORITY,
        PUBLIC
    }
    struct Whitelist {
        bool isWhitelisted;
        WhitelistType whitelistType;
    }

    event Whitelisted(address _user, WhitelistType whitelistType);
    event Blacklisted(address _user);
    event SetOpenForAll(bool _isOpenForAll);

    /**
     * @notice Set the Active Whitelisting Type
     *
     * @param whitelistType - Type of Whitelisting
     */
    function setActiveWhitelistType(WhitelistType whitelistType)
    public
    onlyAdmin
    {
        activeWhitelistType = whitelistType;
    }

    /**
     * @notice Set the NFT purchase limit
     *
     * @param _purchaseLimit - NFT purchase limit
     */
    function setPurchaseLimit(uint256 _purchaseLimit) public onlyAdmin {
        purchaseLimit = _purchaseLimit;
    }

    /**
     * @notice Whitelist User
     *
     * @param user - Address of User
     * @param whitelistType - Type of Whitelisting
     */
    function whitelist(address user, WhitelistType whitelistType)
    public
    onlyAdmin
    {
        _whitelisted[user].isWhitelisted = true;
        _whitelisted[user].whitelistType = whitelistType;
        emit Whitelisted(user, whitelistType);
    }

    /**
     * @notice Whitelist Users
     *
     * @param users - Addresses of Users
     */
    function whitelistBatch(
        address[] memory users,
        WhitelistType[] memory whitelistTypes
    ) external onlyAdmin {
        for (uint256 i = 0; i < users.length; i++) {
            whitelist(users[i], whitelistTypes[i]);
        }
    }

    /**
     * @notice Blacklist User
     *
     * @param user - Address of User
     */
    function blacklist(address user) public onlyAdmin {
        _whitelisted[user].isWhitelisted = false;
        emit Blacklisted(user);
    }

    /**
     * @notice Blacklist Users
     *
     * @param users - Addresses of Users
     */
    function blacklistBatch(address[] memory users) external onlyAdmin {
        for (uint256 i = 0; i < users.length; i++) {
            blacklist(users[i]);
        }
    }

    /**
     * @notice Enable/Dsiable Whitelist Feature
     *
     * @param _isOpenForAll - Enable/Disable Sale for all
     */
    function setOpenForAll(bool _isOpenForAll) external onlyAdmin {
        isOpenForAll = _isOpenForAll;
        emit SetOpenForAll(_isOpenForAll);
    }

    /**
     * @notice Check if Whitelisted
     *
     * @param user - Address of User
     * @return whether user is whitelisted
     */
    function isWhitelisted(address user)
    public
    view
    returns (Whitelist memory)
    {
        return _whitelisted[user];
    }

    /**
     * Throws if NFT purchase limit has exceeded.
     */
    modifier onlyLimited() {
        require(
            userPurchaseCounter[_msgSender()] < purchaseLimit,
            "Purchase limit reached"
        );
        _;
    }

    /**
     * Throws if called by any account other than Whitelisted.
     */
    modifier onlyWhitelisted() {
        require(
            ((_whitelisted[_msgSender()].isWhitelisted) &&
            (_whitelisted[_msgSender()].whitelistType ==
            activeWhitelistType)) ||
            ((_whitelisted[_msgSender()].isWhitelisted) &&
            (_whitelisted[_msgSender()].whitelistType ==
            WhitelistType.PRIORITY)) ||
            _admins[_msgSender()] ||
            _msgSender() == owner() ||
            isOpenForAll,
            "Caller is not Whitelisted"
        );
        _;
    }
}