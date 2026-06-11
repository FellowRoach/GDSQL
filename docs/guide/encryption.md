# Data Encryption

GDSQL provides built-in AES-256-CBC encryption for protecting sensitive game data. Encryption works at both the database level and the table level.

## How It Works

GDSQL uses a **DEK (Data Encryption Key)** hierarchy:

1. **DEK**: A random 256-bit key used to encrypt/decrypt actual data
2. **User Password**: Your chosen password that protects the DEK
3. **Key Derivation**: HMAC-SHA256 with random salt derives the encryption key from your password

This means:
- Data is encrypted with the DEK
- The DEK is encrypted with a key derived from your password
- Even if someone obtains the encrypted DEK, they still need your password

## Password Verification

A built-in verification code is encrypted alongside the DEK. When decrypting, the system first checks this verification code to detect wrong passwords — preventing data corruption from incorrect decryption.

## Encryption Granularity

### Database-Level Encryption

Encrypt an entire database. All tables within it are encrypted.

### Table-Level Encryption

Encrypt individual tables within a database. Other tables remain unencrypted.

## Using Encryption from Code

### Generate a DEK

```gdscript
var dek_base64 = GDSQL.CryptoUtil.generate_dek()
```

### Encrypt the DEK with a Password

```gdscript
var encrypted_dek_data = GDSQL.CryptoUtil.encrypt_dek(dek_base64, "my_password")
# Store encrypted_dek_data somewhere safe (e.g., a config file)
```

### Save Encrypted Config

```gdscript
var cfg = ConfigFile.new()
cfg.set_value("settings", "volume", 80)
GDSQL.CryptoUtil.save_encrypted_config(cfg, dek_base64, "user://settings.cfg")
```

### Load Encrypted Config

```gdscript
# First, decrypt the DEK
var recovered_dek = GDSQL.CryptoUtil.decrypt_dek64(encrypted_dek_data, "my_password")

if recovered_dek != "":
    # Password correct — load the config
    var cfg = ConfigFile.new()
    GDSQL.CryptoUtil.load_encrypted_config(cfg, recovered_dek, "user://settings.cfg")
    print(cfg.get_value("settings", "volume"))  # 80
else:
    print("Wrong password!")
```

### Using with BaseDao

Set the password on the DAO before querying encrypted tables:

```gdscript
var result = GDSQL.BaseDao.new() \
    .use_db("game_config") \
    .set_password("my_password") \
    .select("*") \
    .from("secret_table") \
    .query()
```

## In the Editor

When opening an encrypted database or table in the workbench, GDSQL prompts for a password. Without the correct password, the data cannot be viewed.

## Technical Details

| Component | Implementation |
|-----------|---------------|
| Encryption | AES-256-CBC (via Godot's `AESContext`) |
| Key derivation | HMAC-SHA256 with random 16-byte salt |
| IV | Random 16-byte initialization vector per encryption |
| Padding | PKCS7 |
| Verification | Encrypted "Hello World!" verification code |

## Security Notes

- The DEK should be generated once and stored securely (encrypted with the user's password)
- Choose strong passwords — the security of encrypted data depends on password strength
- Encrypted `.cfg` files are not human-readable — they cannot be edited in a text editor
- Encryption adds a small performance overhead to read/write operations
