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
        - MissionDAO address = 0x0d2C4A0D17DaA28E40064f832285768A8968C8e9
- matic
  - npx hardhat run scripts/deploy.js --network matic

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
- npx hardhat verify --network polygon_mumbai --constructor-args arguments.js 0x0d2C4A0D17DaA28E40064f832285768A8968C8e9
- npx hardhat verify --network matic --constructor-args arguments.js <contract address>
- Relevant packages: hardhat-etherscan

How to make a purchase using ChumbiCloneSale

- Set Sale contract saleenabled or opentoALl to true (You can only buy if you are whitelisted / if there is sale going on)
- Set Sale contract as admin of ChumbiClone contract (Only admins can call transfer function on chumbiclone contract)
