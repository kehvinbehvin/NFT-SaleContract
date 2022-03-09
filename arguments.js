require('dotenv').config();

const { NFT_CONTRACT_ADDRESS, USDC_TESTNET_CONTRACT_ADDRESS } = process.env;


module.exports = [
    NFT_CONTRACT_ADDRESS,
    USDC_TESTNET_CONTRACT_ADDRESS,
    ["300000000"],
    ["ipfs://QmbzAgdALBZSchqyvvDufjCqqXyqqtq3eSRZQxipKYz5EY/pre-reveal.json"],
    5,
];