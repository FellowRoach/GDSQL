# CryptoUtil API 参考

`GDSQL.CryptoUtil` 提供 AES-256-CBC 加密工具方法。

**类**: `Object`（静态方法）  
**命名空间**: `GDSQL.CryptoUtil`  
**源码**: `addons/gdsql/crypto/crypto.gd`

## 密钥管理

### `generate_dek() -> String`
生成随机 256 位 DEK（Base64 格式）。

### `encrypt_dek(dek: String, user_password: String) -> String`
用密码加密 DEK。返回包含解密所需所有信息的复合字符串。

### `decrypt_dek64(encrypted_dek_info: String, user_password: String) -> String`
解密 DEK，返回 Base64 字符串。密码错误返回空字符串。

### `decrypt_dek(encrypted_dek_info: String, user_password: String) -> PackedByteArray`
解密 DEK，返回原始字节。

## 配置文件加密

### `save_encrypted_config(cfg: ConfigFile, dek_base64: String, path: String) -> Error`
AES 加密保存 ConfigFile。

### `load_encrypted_config(cfg: ConfigFile, dek_base64: String, path: String) -> Error`
加载加密的 ConfigFile。

## 完整流程

```gdscript
# 1. 生成并存储 DEK
var dek = GDSQL.CryptoUtil.generate_dek()
var encrypted_dek = GDSQL.CryptoUtil.encrypt_dek(dek, "密码")

# 2. 加密数据
var cfg = ConfigFile.new()
cfg.set_value("player", "name", "英雄")
GDSQL.CryptoUtil.save_encrypted_config(cfg, dek, "user://data.cfg")

# 3. 解密读取
var recovered_dek = GDSQL.CryptoUtil.decrypt_dek64(encrypted_dek, "密码")
if recovered_dek != "":
    var loaded_cfg = ConfigFile.new()
    GDSQL.CryptoUtil.load_encrypted_config(loaded_cfg, recovered_dek, "user://data.cfg")
```

## 技术细节

| 组件 | 值 |
|------|-----|
| 算法 | AES-256-CBC |
| 密钥大小 | 256 位 |
| IV | 每次加密随机 16 字节 |
| 盐值 | 每次 DEK 加密随机 16 字节 |
| 密钥派生 | HMAC-SHA256 |
| 填充 | PKCS7 |
