# IV3EXCheckIn 接口文档

`IV3EXCheckIn` 是一个用于用户签到、打赏以及管理费用的接口。

## 事件

### `UserCheckIn`

当用户在特定日期签到时触发。

**事件签名**

```solidity
event UserCheckIn(address indexed user, uint256 date, uint256 amount);
```

参数
- `user` (address): 签到的用户地址。
- `date` (uint256): 签到日期。
- `amount` (uint256): 与签到相关的数量，该值不能为零。

----------
### `SignerUpdated`

当签名者地址更新时触发。

**事件签名**

```solidity
event SignerUpdated(address signer);
```

参数
- `signer` (address):  新的签名者地址，该地址不能为零地址。

----------
### `TipSent`

当用户打赏时触发。

**事件签名**

```solidity
event TipSent(address indexed from, address indexed to, uint256 amount, address tokenAddress);
```

参数
- `from` (address): 发送打赏的用户地址。
- `to` (address): 接收打赏的用户地址。
- `amount` (uint256): 打赏金额。
- `tokenAddress` (address): 用于打赏的代币地址，该地址不能为零地址。

----------
### `FeeCollected`

当收取手续费时触发。

**事件签名**

```solidity
event FeeCollected(address indexed tokenAddress, uint256 amount);
```

参数
- `tokenAddress` (address): 收取手续费的代币地址。
- `amount` (uint256): 收集的手续费用金额。

----------
### `FeePercentageChanged`

当手续费百分比改变时触发。

**事件签名**

```solidity
event FeePercentageChanged(uint256 oldFee, uint256 newFee);
```

参数
- `oldFee` (uint256):  旧的手续费百分比。
- `newFee` (uint256):  新的手续费百分比。

----------
### `WithdrawFee`

当收取的手续费被提取时触发。

**事件签名**

```solidity
event WithdrawFee(address indexed tokenAddress, address indexed to, uint256 amount);
```

参数
- `tokenAddress` (address): 用于提取的代币地址。
- `to` (address): 提取手续费的接收地址。
- `amount` (uint256): 提取的手续费金额。

----------
## 接口

-------------
### `checkIn`

允许用户以指定的日期和金额进行签到。

**函数签名**

```solidity
function checkIn(uint256 date, uint256 amount, string memory transId, bytes memory signature) external;
```
参数
- `date` (uint256): 签到日期。
- `amount` (uint256): 签到奖励金额。
- `transId` (string memory): 签到的交易 ID。
- `signature` (bytes memory): 用于验证签到的签名。

示例
```solidity
IV3EXCheckIn.checkIn(20240621, 100, "txn123", signature);
```

-------------
### `haveCheckedIn`

检查用户是否在特定日期签到。

**函数签名**

```solidity
function haveCheckedIn(address user, uint256 date) external returns (bool state);
```
参数
- `user` (address): 用户地址。
- `date` (uint256): 检查的日期。

返回
- `state` (bool): 表示用户是否在指定日期签到。

示例
```solidity
bool state = IV3EXCheckIn.haveCheckedIn("0x1234567890abcdef1234567890abcdef12345678", 20240621);
```
-------------
### `checkInStates`

检查用户是否在多个特定日期签到。

**函数签名**

```solidity
function checkInStates(address user, uint256[] memory dates) external returns (bool[] memory states);
```
参数
- `user` (address): 用户地址。
- `dates` (uint256[]): 检查的日期数组。

返回
- `states` (bool[]):  表示用户是否在每个指定日期签到的布尔数组。

示例
```solidity
uint256[] memory dates = new uint256[](3);
dates[0] = 20240621;
dates[1] = 20240622;
dates[2] = 20240623;
bool[] memory states = IV3EXCheckIn.checkInStates("0x1234567890abcdef1234567890abcdef12345678", dates);
```
-------------
### `existsTransId`

检查交易 ID 是否存在。

**函数签名**

```solidity
function existsTransId(string memory transId) external returns (bool exists);
```
参数
- `transId` (string): 检查的交易 ID。

返回
- `exists` (bool): 如果交易 ID 存在则返回 true，否则返回 false。

示例
```solidity
bool exists = IV3EXCheckIn.existsTransId("txn123");
```
-------------
### `toMessageHash`

生成用于签名验证的消息哈希。

**函数签名**

```solidity
function toMessageHash(uint256 chainId, string memory code, string memory transId, uint256 amount, address to) external returns (bytes32);
```
参数
- `chainId` (uint256): 区块链链 ID。
- `code` (string memory): 操作码。
- `transId` (string memory): 交易 ID。
- `amount` (uint256): 奖励金额。
- `to` (address): 目标地址。

返回
- `messageHash` (bytes32): 生成的消息哈希。

示例
```solidity
bytes32 hash = IV3EXCheckIn.toMessageHash(1, "CHECKIN", "txn123", 100, "0x1234567890abcdef1234567890abcdef12345678");
```
-------------
### `verifySignature`

验证签到的签名。

**函数签名**

```solidity
function verifySignature(string memory code, string memory transId, uint256 amount, address to, bytes memory signature) external returns (bool);
```
参数
- `code` (string memory): 操作码。
- `transId` (string memory): 交易 ID。
- `amount` (uint256): 奖励金额。
- `to` (address): 目标地址。
- `signature` (bytes memory): 用于验证的签名。

返回
- `verified` (bool): 如果签名有效则返回 true，否则返回 false。

示例
```solidity
bool verified = IV3EXCheckIn.verifySignature("checkin", "txn123", 100, "0x1234567890abcdef1234567890abcdef12345678", signature);
```
-------------
### `getSigner`

返回当前签名者地址。

**函数签名**

```solidity
function getSigner() external returns (address);
```
返回
- `signer` (address): 当前签名者地址。

示例
```solidity
address signer = IV3EXCheckIn.getSigner();
```
-------------
### `setSigner`

设置新的签名者地址。

**函数签名**

```solidity
function setSigner(address addr) external;
```
参数
- `addr` (address): 新的签名者地址。

示例
```solidity
IV3EXCheckIn.setSigner("0x1234567890abcdef1234567890abcdef12345678");
```
-------------
### `tipERC20`

打赏 ERC20 代币到指定地址。

**函数签名**

```solidity
function tipERC20(address tokenAddress, address to, uint256 amount) external;
```
参数
- `tokenAddress` (address): ERC20 代币合约地址。
- `to` (address): 被打赏的地址。
- `amount` (uint256): 打赏金额。

示例
```solidity
IV3EXCheckIn.tipERC20("0xTokenAddress", "0xRecipientAddress", 100);
```
-------------
### `tipETH`

打赏原生代币到指定地址。

**函数签名**

```solidity
function tipETH(address to) external payable;
```
参数
- `to` (address): 被打赏的地址。

示例
```solidity
IV3EXCheckIn.tipETH{value: 1 ether}("0xRecipientAddress");
```
-------------
### ``setFeePercentage``

设置新的打赏手续费百分比。

**函数签名**

```solidity
function setFeePercentage(uint256 newFeePercentage) external;
```
参数
- `newFeePercentage` (uint256): 新的打赏手续费百分比，1%=100。

示例
```solidity
IV3EXCheckIn.setFeePercentage(200);
```
-------------
### `withdrawCollectedFees`

提取收集的费用到指定地址。

**函数签名**

```solidity
function withdrawCollectedFees(address tokenAddress, address to, uint256 amount) external;
```
参数
- `tokenAddress` (address): 用于提取费用的代币地址，0地址，表示原生代币。
- `to` (address): 提取费用的接收地址。
- `amount` (uint256): 提取的费用金额。

示例
```solidity
IV3EXCheckIn.withdrawCollectedFees("0xTokenAddress", "0xRecipientAddress", 100);
```
-------------
### `withdrawStuckToken`

提取卡住的代币到指定地址。

**函数签名**

```solidity
function withdrawStuckToken(address tokenAddress, address to) external;
```
参数
- `tokenAddress` (address): 提取的代币地址，0地址，表示原生代币。
- `to` (address): 提取代币的接收地址。

示例
```solidity
IV3EXCheckIn.withdrawStuckToken("0xTokenAddress", "0xRecipientAddress");
```
-------------