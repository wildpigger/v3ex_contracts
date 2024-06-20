# IV3EXToken 接口文档

`IV3EXToken` 是一个符合 `IERC20Upgradeable` 接口的合约，并扩展了一些额外的功能。

## 接口

-------------
### `mint`

创建 `amount` 数量的代币并分配给 `to` 地址，增加总供应量。

**函数签名**

```solidity
function mint(address to, uint256 amount) external;
```
参数
- `to` (address): 接收代币的用户地址，不能是零地址。
- `amount` (uint256): 铸造的代币数量。
示例
```
IV3EXToken.mint("0x1234567890abcdef1234567890abcdef12345678", 1000);
```
-------------
### `pause`

冻结合约。

**函数签名**

```solidity
function pause() external;
```
示例
```
IV3EXToken.pause();
```
-------------
### `unpause`

恢复合约状态。

**函数签名**

```solidity
function unpause() external;
```
示例
```
IV3EXToken.unpause();
```

-------------