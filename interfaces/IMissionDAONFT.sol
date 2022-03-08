// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IMissionDAONFT is IERC721 {
    function mint(
        address recipient,
        uint256 tokenId,
        string memory URI
    ) external;
}