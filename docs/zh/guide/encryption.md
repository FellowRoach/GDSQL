# 数据加密

GDSQL 提供内置的 AES-256-CBC 加密，保护敏感游戏数据。支持数据库级和表级加密。

## 工作原理

GDSQL 使用 **DEK（数据加密密钥）** 体系：

1. **DEK**：随机生成的 256 位密钥，用于加密/解密实际数据
2. **用户密码**：你选择的密码，保护 DEK
3. **密钥派生**：HMAC-SHA256 + 随机盐值从密码派生加密密钥

## 密码验证

内置验证码与 DEK 一起加密。解密时先检查验证码，检测密码错误——防止错误解密导致数据损坏。

## 加密粒度

- **数据库级加密**：加密整个数据库，其中所有表都被加密
- **表级加密**：加密数据库中的个别表，其他表保持未加密

## 代码使用

### 生成 DEK

```gdscript
var dek_base64 = GDSQL.CryptoUtil.generate_dek()
```

### 用密码加密 DEK

```gdscript
var encrypted_dek_data = GDSQL.CryptoUtil.encrypt_dek(dek_base64, "我的密码")
```

### 保存加密配置

```gdscript
var cfg = ConfigFile.new()
cfg.set_value("settings", "volume", 80)
GDSQL.CryptoUtil.save_encrypted_config(cfg, dek_base64, "user://settings.cfg")
```

### 加载加密配置

```gdscript
var recovered_dek = GDSQL.CryptoUtil.decrypt_dek64(encrypted_dek_data, "我的密码")
if recovered_dek != "":
    var cfg = ConfigFile.new()
    GDSQL.CryptoUtil.load_encrypted_config(cfg, recovered_dek, "user://settings.cfg")
else:
    print("密码错误！")
```

### 配合 BaseDao 使用

```gdscript
var result = GDSQL.BaseDao.new() \
    .use_db("game_config") \
    .set_password("我的密码") \
    .select("*").from("secret_table") \
    .query()
```

## 技术细节

| 组件 | 实现 |
|------|------|
| 加密算法 | AES-256-CBC（通过 Godot 的 `AESContext`） |
| 密钥派生 | HMAC-SHA256 + 16字节随机盐 |
| IV | 每次加密随机 16 字节 |
| 填充 | PKCS7 |
| 验证 | 加密的 "Hello World!" 验证码 |
