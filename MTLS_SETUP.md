# mTLS Setup Tutorial for Spring Boot Application

This guide explains how to add mTLS support.

## 📁 Files Added/Modified

### Certificate Generation Script
- **`scripts/client-cert.sh`** - Generates client keys, certs, fullchain_client.p12 and truststore.p12

### Certificate Extension Files
- **`scripts/client.ext`** - Defines client certificate usage and hostname validation

### Spring Boot Configuration
- **`src/main/resources/application.yaml`** - mTLS configuration for HTTPS on port 8443
- **`.env.example`** - Environment variable template for keystore password

## 🔐 Certificate Chain Generation

Run the certificate generation script:

```bash
cd scripts
chmod +x client-cert.sh
./client-cert.sh
```

The script creates:
1. **Client Certificate** (2048-bit RSA, 1 year validity)
2. **PKCS#12 Bundle** (`fullchain_client.p12`) for Spring Boot
3. **Truststore** (`truststore.p12`) containing Root CA for client authentication

## ⚙️ Spring Boot TLS Configuration

### 1. Environment Variables
Create `.env` file from `.env.example`:
```bash
cp .env.example .env
# Edit .env to set your keystore password
```

### 2. Application Configuration
The `application.yaml` configures:
- **Truststore**: `classpath:trust/truststore.p12`
- **Password**: From environment variable `$SERVER_SSL_TRUST_STORE_PASSWORD`
- **Type**: PKCS12 format
- **Client-auth**: `need` (enforces client certificate authentication)

### 3. Certificate Installation
**Important**: Install `fullchain_client.p12` in your system's trust store:

**Windows/macOS:**
- Double-click on the file and follow the prompts to add it to the system's trusted certificates.

**Linux:**
- Update in browser

## 🚀 Running the Application

```bash
# Set environment variable using .env file
export $(cat .env | xargs)

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
| `client.key` | Client private key | 🔴 Keep secure |
| `client.crt` | Client certificate | Standard |
| `fullchain_client.crt` | Client cert + chain | For client authentication |
| `fullchain_client.p12` | PKCS#12 bundle for client | For Java applications |
| `truststore.p12` | Truststore containing Root CA | For client trust validation |

## 🔍 Verification

Test your TLS setup:
```bash
# Check certificate chain
openssl s_client -connect localhost:8443 -servername localhost

# Verify certificate details
openssl x509 -in scripts/client.crt -text -noout
```

## 🛡️ Security Notes

- **Private keys** are encrypted with AES-256
- **Certificate chain** provides proper PKI hierarchy
- **Extensions** enforce security constraints
- **Subject Alternative Names** support localhost and 127.0.0.1

Your Spring Boot application now supports secure with mTLS connections! 🔒</content>
