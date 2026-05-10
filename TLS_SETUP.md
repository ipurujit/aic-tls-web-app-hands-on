# TLS Setup Tutorial for Spring Boot Application

This guide explains how to add TLS (HTTPS) support to your Spring Boot application using a custom certificate chain.

## 📁 Files Added/Modified

### Certificate Generation Script
- **`scripts/cert-chain.sh`** - Generates complete SSL/TLS certificate chain (Root CA → Intermediate CA → Server Certificate)

### Certificate Extension Files
- **`scripts/intermediate.ext`** - Defines intermediate CA constraints and key usage
- **`scripts/localhost.ext`** - Defines server certificate usage and hostname validation

### Spring Boot Configuration
- **`src/main/resources/application.yaml`** - SSL configuration for HTTPS on port 8443
- **`.env.example`** - Environment variable template for keystore password

## 🔐 Certificate Chain Generation

Run the certificate generation script:

```bash
cd scripts
chmod +x cert-chain.sh
./cert-chain.sh
```

The script creates:
1. **Root CA** (4096-bit RSA, 10 years validity)
2. **Intermediate CA** (4096-bit RSA, 5 years validity)
3. **Server Certificate** (2048-bit RSA, 1 year validity)
4. **PKCS#12 Bundle** (`fullchain.p12`) for Spring Boot

## ⚙️ Spring Boot TLS Configuration

### 1. Environment Variables
Create `.env` file from `.env.example`:
```bash
cp .env.example .env
# Edit .env to set your keystore password
```

### 2. Application Configuration
The `application.yaml` configures:
- **Port**: 8443 (standard HTTPS port)
- **Keystore**: `classpath:keys/fullchain.p12`
- **Password**: From environment variable `$SERVER_SSL_KEY_STORE_PASSWORD`
- **Type**: PKCS12 format
- **Alias**: `localhost`

### 3. Certificate Installation
**Important**: Install `rootCA.crt` in your system's trust store:

**Windows:**
- Import `rootCA.crt` → Trusted Root Certification Authorities

**macOS:**
- Double-click `rootCA.crt` → System keychain

**Linux:**
```bash
sudo cp scripts/rootCA.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

## 🚀 Running the Application

```bash
# Set environment variable
export SERVER_SSL_KEY_STORE_PASSWORD=your_password_here

# Run Spring Boot app
./mvnw spring-boot:run
```

Access your application at: `https://localhost:8443`

## 📋 Certificate Files Overview

| File | Purpose | Security Level |
|------|---------|----------------|
| `rootCA.key` | Root CA private key | 🔴 Keep secure |
| `rootCA.crt` | Root CA certificate | Install in trust store |
| `intermediate.key` | Intermediate CA private key | 🔴 Keep secure |
| `intermediate.crt` | Intermediate CA certificate | Standard |
| `localhost.key` | Server private key | 🔴 Keep secure |
| `localhost.crt` | Server certificate | Standard |
| `fullchain.crt` | Complete chain (server + intermediate) | For web servers |
| `fullchain.p12` | PKCS#12 bundle | For Java applications |

## 🔍 Verification

Test your TLS setup:
```bash
# Check certificate chain
openssl s_client -connect localhost:8443 -servername localhost

# Verify certificate details
openssl x509 -in scripts/localhost.crt -text -noout
```

## 🛡️ Security Notes

- **Private keys** are encrypted with AES-256
- **Certificate chain** provides proper PKI hierarchy
- **Extensions** enforce security constraints
- **Subject Alternative Names** support localhost and 127.0.0.1

Your Spring Boot application now supports secure HTTPS connections! 🔒</content>
