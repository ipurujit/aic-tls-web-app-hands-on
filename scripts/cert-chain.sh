#!/bin/bash
# cert-chain.sh
# Combined script to generate a complete SSL/TLS certificate chain
# This script generates: Root CA -> Intermediate CA -> Server Certificate
set -e

# Color codes
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

mkdir -p output output/root output/intermediate output/server output/client

echo "=========================================="
echo -e "${BOLD}SSL/TLS Certificate Chain Generation Script${NC}"
echo "=========================================="
echo ""

# ==================== ROOT CA GENERATION ====================
echo -e "${RED}${BOLD}### STEP 1: Generating Root CA ###${NC}"

echo -e "${RED}>>> Generating private key for Root CA (4096-bit RSA)${NC}"
echo -e "${BLUE}    NOTE: Enter passphrase to protect Root CA private key${NC}"
echo ""
openssl genrsa -aes256 -out output/root/rootCA.key 4096

echo ""
echo -e "${RED}>>> Generating self-signed X.509 certificate for Root CA${NC}"
echo -e "${BLUE}    NOTE: Re-enter passphrase for Root CA private key${NC}"
echo ""
MSYS_NO_PATHCONV=1 openssl req -x509 -new -nodes -key output/root/rootCA.key -sha256 -days 3650 -out output/root/rootCA.crt \
    -config root.conf -extensions v3_ca

echo -e "${GREEN}✓ Root CA created: rootCA.key and rootCA.crt (3650 days)${NC}"
echo ""

# ==================== INTERMEDIATE CA GENERATION ====================
echo -e "${YELLOW}${BOLD}### STEP 2: Generating Intermediate CA ###${NC}"

echo -e "${YELLOW}>>> Generating private key for Intermediate CA (4096-bit RSA)${NC}"
echo -e "${BLUE}    NOTE: Enter passphrase for Intermediate CA private key${NC}"
echo ""
openssl genrsa -aes256 -out output/intermediate/intermediate.key 4096

echo ""
echo -e "${YELLOW}>>> Generating Certificate Signing Request (CSR) for Intermediate CA${NC}"
echo -e "${BLUE}    NOTE: Re-enter passphrase for Intermediate CA private key${NC}"
echo ""
MSYS_NO_PATHCONV=1 openssl req -new -key output/intermediate/intermediate.key -out output/intermediate/intermediate.csr \
    -config intermediate.conf

echo ""
echo -e "${YELLOW}>>> Signing Intermediate CA CSR with Root CA${NC}"
echo -e "${BLUE}    NOTE: Enter passphrase for Root CA private key${NC}"
echo -e "${BLUE}    WHY EXTENSIONS? They define CA constraints and chain length limits${NC}"
echo ""
openssl x509 -req -in output/intermediate/intermediate.csr \
    -CA output/root/rootCA.crt -CAkey output/root/rootCA.key -CAcreateserial \
    -out output/intermediate/intermediate.crt -days 1825 -sha256 \
    -extfile intermediate.conf -extensions v3_intermediate_ca

echo -e "${GREEN}✓ Intermediate CA created: intermediate.crt (1825 days)${NC}"
echo ""

# ==================== SERVER CERTIFICATE GENERATION ====================
echo -e "${GREEN}${BOLD}### STEP 3: Generating Server Certificate for localhost ###${NC}"
echo ""

echo -e "${GREEN}>>> Generating private key for Server (2048-bit RSA)${NC}"
openssl genrsa -out output/server/server.key 2048

echo ""
echo -e "${GREEN}>>> Generating Certificate Signing Request (CSR) for Server${NC}"
MSYS_NO_PATHCONV=1 openssl req -new -key output/server/server.key -out output/server/server.csr \
    -config server.conf

echo ""
echo -e "${GREEN}>>> Signing Server Certificate with Intermediate CA${NC}"
echo -e "${BLUE}    NOTE: Enter passphrase for Intermediate CA private key${NC}"
echo -e "${BLUE}    WHY EXTENSIONS? They specify key usage, authentication, and hostname validation${NC}"
echo ""
openssl x509 -req -in output/server/server.csr -CA output/intermediate/intermediate.crt -CAkey output/intermediate/intermediate.key \
    -CAcreateserial -out output/server/server.crt -days 365 -sha256 \
    -extfile server.conf -extensions v3_server_req

echo -e "${GREEN}✓ Server Certificate created: server.crt (365 days)${NC}"
echo ""

# ==================== CERTIFICATE CHAIN CONVERSION ====================
echo -e "${BOLD}### STEP 4: Creating Full Certificate Chain and Converting to PKCS#12 ###${NC}"
echo ""

echo ">>> Creating certificate chain (concatenating server cert + intermediate cert)"
cat output/server/server.crt output/intermediate/intermediate.crt > output/fullchain.crt

echo ">>> Converting Server Certificate to PKCS#12 format (.p12)"
echo -e "${BLUE}    NOTE: Enter NEW passphrase for PKCS#12 file (different from private key passphrases)${NC}"
echo ""
MSYS_NO_PATHCONV=1 openssl pkcs12 -export -in output/fullchain.crt -inkey output/server/server.key \
    -name "server" -out output/fullchain.p12

echo -e "${GREEN}✓ Certificate chain conversion complete!${NC}"
echo ""

# ==================== IMPORTANT INSTRUCTIONS ====================
echo -e "${BOLD}==========================================${NC}"
echo -e "${BOLD}${RED}### IMPORTANT: Next Steps ###${NC}"
echo -e "${BOLD}==========================================${NC}"

echo -e "${YELLOW} CERTIFICATE FILES CREATED:${NC}"
echo -e "${RED}    • rootCA.key: Root CA private key (KEEP SECURE)${NC}"
echo -e "${RED}    • rootCA.crt: Root CA certificate (install in trust store)${NC}"
echo -e "${YELLOW}    • intermediate.key: Intermediate CA private key (KEEP SECURE)${NC}"
echo -e "${YELLOW}    • intermediate.crt: Intermediate CA certificate${NC}"
echo -e "${GREEN}    • server.key: Server private key${NC}"
echo -e "${GREEN}    • server.crt: Server certificate${NC}"
echo -e "${GREEN}    • fullchain.crt: Complete certificate chain${NC}"
echo -e "${GREEN}    • fullchain.p12: PKCS#12 bundle for applications${NC}"
echo ""
echo -e "${BOLD}==========================================${NC}"
echo -e "${GREEN}✓ Certificate chain generation completed successfully!${NC}"
echo -e "${BOLD}==========================================${NC}"

echo ""
echo -e "${BOLD}1. Copy 'output/fullchain.p12' to your application's keystore location 'src/main/resources/keys/fullchain.p12'${NC}"

echo ""
echo -e "${BOLD}2. Update 'src/main/resources/application.yaml' property 'server.ssl.key-store-password' to your EXPORT password${NC}"

echo ""
echo -e "${BOLD}3. LOAD ROOT CERTIFICATE INTO LOCAL MACHINE:${NC}"
echo -e "${BLUE}    The rootCA.crt must be installed in your system's trust store${NC}"
echo -e "${BLUE}    - Windows: Import rootCA.crt → 'Trusted Root Certification Authorities'${NC}"
echo -e "${BLUE}    - macOS: Double-click rootCA.crt → 'System' keychain${NC}"
echo -e "${BLUE}    - Linux: sudo cp output/root/rootCA.crt /usr/local/share/ca-certificates/tls-demo-rootCA.crt && sudo update-ca-certificates${NC}"
echo ""
