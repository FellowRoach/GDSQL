# CryptoUtil API Reference

`GDSQL.CryptoUtil` provides AES-256-CBC encryption utilities for protecting sensitive data.

**Class**: `Object` (static methods)  
**Namespace**: `GDSQL.CryptoUtil`  
**Source**: `addons/gdsql/crypto/crypto.gd`

## Key Management

### `generate_dek() -> String`
Generate a random 256-bit Data Encryption Key (DEK), returned as a Base64 string.

```gdscript
var dek = GDSQL.CryptoUtil.generate_dek()
# e.g., "aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890ABCD="
```

### `encrypt_dek(dek: String, user_password: String) -> String`
Encrypt a DEK with a user password. Returns a composite string containing all data needed for decryption.

**Parameters:**
- `dek` — The DEK Base64 string from `generate_dek()`
- `user_password` — The user's password

**Returns:** A pipe-delimited string: `encrypted_dek|iv|salt|verify_code|verify_iv`

```gdscript
var encrypted_data = GDSQL.CryptoUtil.encrypt_dek(dek, "my_password")
# Store this string securely
```

### `decrypt_dek64(encrypted_dek_info: String, user_password: String) -> String`
Decrypt a DEK and return it as a Base64 string. Returns empty string on wrong password.

```gdscript
var dek = GDSQL.CryptoUtil.decrypt_dek64(encrypted_data, "my_password")
if dek == "":
    print("Wrong password!")
```

### `decrypt_dek(encrypted_dek_info: String, user_password: String) -> PackedByteArray`
Decrypt a DEK and return raw bytes. Returns empty `PackedByteArray` on wrong password.

## Config File Encryption

### `save_encrypted_config(cfg: ConfigFile, dek_base64: String, path: String) -> Error`
Save a ConfigFile with AES encryption.

```gdscript
var cfg = ConfigFile.new()
cfg.set_value("game", "score", 9999)
var err = GDSQL.CryptoUtil.save_encrypted_config(cfg, dek, "user://save.cfg")
```

### `load_encrypted_config(cfg: ConfigFile, dek_base64: String, path: String) -> Error`
Load an encrypted ConfigFile.

```gdscript
var cfg = ConfigFile.new()
var err = GDSQL.CryptoUtil.load_encrypted_config(cfg, dek, "user://save.cfg")
if err == OK:
    print(cfg.get_value("game", "score"))
```

## Technical Details

| Component | Value |
|-----------|-------|
| Algorithm | AES-256-CBC |
| Key size | 256 bits (32 bytes) |
| IV | Random 16 bytes per encryption |
| Salt | Random 16 bytes per DEK encryption |
| Key derivation | HMAC-SHA256(salt, password) |
| Padding | PKCS7 |
| Verification | Encrypted "Hello World!" check |

## Complete Workflow

```gdscript
# 1. First-time setup: generate and store DEK
var dek = GDSQL.CryptoUtil.generate_dek()
var encrypted_dek = GDSQL.CryptoUtil.encrypt_dek(dek, "user_password")
# Save encrypted_dek to a config file or secure storage

# 2. Encrypt data
var cfg = ConfigFile.new()
cfg.set_value("player", "name", "Hero")
cfg.set_value("player", "level", 50)
GDSQL.CryptoUtil.save_encrypted_config(cfg, dek, "user://data.cfg")

# 3. Later: decrypt and read
var recovered_dek = GDSQL.CryptoUtil.decrypt_dek64(encrypted_dek, "user_password")
if recovered_dek != "":
    var loaded_cfg = ConfigFile.new()
    GDSQL.CryptoUtil.load_encrypted_config(loaded_cfg, recovered_dek, "user://data.cfg")
    print(loaded_cfg.get_value("player", "name"))  # "Hero"
else:
    print("Wrong password!")
```
