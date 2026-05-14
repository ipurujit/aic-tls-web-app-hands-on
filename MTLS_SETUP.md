# mTLS Setup Tutorial for Spring Boot Application

This guide explains how to implement **Mutual TLS (mTLS)** support. In this configuration, the server validates the client's identity using a truststore, and the client validates the server using a keystore.

## 📁 Files Added/Modified

### Certificate Generation Script

* **`scripts/client-cert.sh`** - Automates client key generation, CSR signing via Intermediate CA, and truststore creation.

### Certificate Extension Files

* **`scripts/client.conf`** - Defines client certificate identity (CN=localhost), usage constraints (CA:FALSE), and SANs (`localhost`, `127.0.0.1`).

### Spring Boot Configuration

* **`src/main/resources/application.yaml`** - Configures `server.ssl.client-auth: need` and points to the new truststore.
* **`.env.example`** - Template for `SERVER_SSL_KEY_STORE_PASSWORD` and `SERVER_SSL_TRUST_STORE_PASSWORD`.

## 🔐 Client Certificate & Truststore Generation

Run the client generation script:

```bash
cd scripts
chmod +x client-cert.sh
./client-cert.sh

```

The script performs the following:

1. **Client Private Key**: Generates a 2048-bit RSA key (`client.key`).
2. **Client Certificate**: Signs a CSR with the Intermediate CA for 365 days of validity (`client.crt`).
3. **PKCS#12 Bundle**: Merges the client cert and intermediate cert into `fullchain_client.p12` for browser/app import.
4. **Truststore**: Uses `keytool` to create `truststore.p12` containing the **Root CA**, allowing the server to verify any client cert signed by this chain.

## ⚙️ Spring Boot mTLS Configuration

### 1. Environment Variables

Create `.env` file to manage sensitive passwords:

```bash
cp .env.example .env
# Set SERVER_SSL_TRUST_STORE_PASSWORD (min 6 characters for keytool)

```

### 2. Application Configuration

The `application.yaml` must be updated to enforce identity:

* **Truststore Path**: `classpath:trust/truststore.p12`.
* **Client Authentication**: Set to `need` to reject any connection without a valid client certificate.

### 3. Client Certificate Installation

To access the application via a browser (e.g., Brave, Chrome):

* **Windows/macOS**: Double-click `output/fullchain_client.p12` to install it into your personal certificate store.
* **Brave/Chrome**: Go to `brave://certificate-manager/` and import the `.p12` file under "Your Certificates".

## 🚀 Running the Application

```bash
# Load passwords into environment
export $(cat .env | xargs)

# Run Spring Boot app
./mvnw spring-boot:run

```

Access your application at: `https://localhost:8443`. The browser will now prompt you to select the "client" certificate you just installed.

## 📋 Certificate Files Overview

| File | Purpose | Security Level |
| --- | --- | --- |
| `client.key` | Client private key | 🔴 Keep secure |
| `client.crt` | Client certificate | Standard |
| `fullchain_client.p12` | PKCS#12 bundle (Cert + Key) | 🔴 Import to Browser |
| `truststore.p12` | Server-side store of trusted Root CAs | 🟡 Copy to `src/main/resources/trust/` |

## 🔍 Verification

Test the mTLS handshake:

```bash
# Verify that the server requests a client certificate
openssl s_client -connect localhost:8443 -brief

```

## 🛡️ Security Notes

* **AuthorityKeyIdentifier**: The `keyid:always,issuer` directive ensures the client certificate correctly points to the Intermediate CA.
* **Pathlen**: The intermediate CA's `pathlen:0` prevents this client certificate from being used to sign further certificates.
* **SAN Validation**: Modern clients require the `subjectAltName` (localhost) to match the URL exactly.

Your Spring Boot application now supports secure with mTLS connections! 🔒