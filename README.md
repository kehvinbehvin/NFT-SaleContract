Setup
- npm install
- add .env file, see below
- compile contract
- deploy contract to testnet
- verify and publish contract

Tests
- npx hardhat compile
- npx hardhat test

Pre-Deployment checks
- Node provider api url
- Etherscan/Polygonscan api key for verification
- Signer private key. eg: your metamask private key

Deployment flow
- npx hardhat compile
- npx hardhat run scripts/<deployment script> --network <your network> --constructor-args
- mumbai
    - npx hardhat run scripts/deploy.js --network polygon_mumbai
        - ChumbiCloneSale address = 0x4a309a504F5C0dce335349dBeCB96dDe51C206F1

Create .env file
- include your API KEY for which ever node provider you are using
    - ensure you have 1 variable for the API_URL and one for the API_KEY for the service provider
- include your wallet private key and public key
    - private key for signing transactions
    - public key for deploying contract
- include the addresses for ERC20 and ERC721 contracts.
- include polygonscan api key to verify and publish contract after deployment

Interacting with your contract (Broken)
- npx hardhat run scripts/interact.js
- You need 3 things to interact with your smart contract
    1. Your node provider api_key
    2. Your wallet
    3. Your contract abi which will be used to retrieve your contract
- Relevant packages: ethers

Retrieving your contract address
- for some reason, the contract address being printed during deploy.js is not accurate.
- retrieving it using eth_getTransactionReceipt.contractAddress is the correct address. You can
- find this one your node provider.

Verifying Contract on Etherscan/Polygonscan
- npx hardhat verify --network polygon_mumbai --constructor-args arguments.js 0xdC1911aBcDCf1a2bda45472f9FE9B87328F935c7
- Relevant packages: hardhat-etherscan

How to make a purchase using ChumbiCloneSale

- Set chumbiSaleClone saleenabled or opentoALl to true (You can only buy if you are whitelisted / if there is sale going on)
- Set ChumbiSaleClone contract as admin of ChumbiClone contract (Only admins can call transfer function on chumbiclone contract)
- Get erc20token from metamaskwallet address = 0x237c2E322dA2A0000955d9EbE4b6ce111E1FA37a
- Give approval to ChumbiCloneSale to make a transfer of tokens from your wallet to the ChumbiCloneSale contract
    - Call approve function on ChumbiCloneERC20Token contract = 0x95B647fA16bcc5cA8c808B76B1bEeDAB4efb0Ef4
        - Approve spender as ChumbiCloneSale contract = 0x4a309a504F5C0dce335349dBeCB96dDe51C206F1
        - Can check transaction by calling allowance function, provide your wallet address and the ChumbiSaleClone contract
    - Call purchase function on ChumbiCloneERC20Token contract = 0x95B647fA16bcc5cA8c808B76B1bEeDAB4efb0Ef4
        - Pass in nfttype number
