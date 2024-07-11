# linea sepolia
source .env && forge script --target-contract V3EXDeploy --rpc-url ${LINEA_SEPOLIA_RPC_URL} --broadcast -vvvv script/V3EX.s.sol

forge verify-contract --etherscan-api-key ${LINEASCAN_API_KEY} --verifier-url https://api-sepolia.lineascan.build/api 0xDA90304768532F7D70BF28A4edf95569fC300002 src/V3EXToken.sol:V3EXToken

forge verify-contract --etherscan-api-key ${LINEASCAN_API_KEY} --verifier-url https://api-sepolia.lineascan.build/api 0xC82D11F51769ebedFceC8DE6ff4eE6f860eB556B src/V3EXCheckIn.sol:V3EXCheckIn

# scroll sepolia
source .env && forge script --target-contract V3EXDeploy --rpc-url ${SCROLL_SEPOLIA_RPC_URL} --broadcast -vvvv script/V3EX.s.sol

forge verify-contract --etherscan-api-key ${SCROLL_API_KEY} --verifier-url https://api-sepolia.scrollscan.com/api 0xcB08b33533Fa5f8375D94a03a29Ee07AC4CA60e9 src/V3EXToken.sol:V3EXToken

forge verify-contract --etherscan-api-key ${SCROLL_API_KEY} --verifier-url https://api-sepolia.scrollscan.com/api 0xa1916dC20d6685348FEECF45cAF22DbfA860346d src/V3EXCheckIn.sol:V3EXCheckIn
