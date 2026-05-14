#!/bin/bash
# This script generates a client certificate for localhost, signed by the Intermediate CA.
# It creates a private key, CSR, signs it with the Intermediate CA,
# and converts it to PKCS#12 format for browser/client app use.

set -e

# Color codes
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ==================== CLIENT CERTIFICATE GENERATION ====================
echo -e "${GREEN}${BOLD}### STEP 1: Generating Client Certificate for localhost ###${NC}"
echo ""

echo -e "${GREEN}>>> Generating private key for Client (2048-bit RSA)${NC}"
openssl genrsa -out output/client/client.key 2048

echo ""
echo -e "${GREEN}>>> Generating Certificate Signing Request (CSR) for Client${NC}"
openssl req -new -key output/client/client.key -out output/client/client.csr \
    -config client.conf

echo ""
echo -e "${GREEN}>>> Signing Client Certificate with Intermediate CA${NC}"
echo -e "${BLUE}    NOTE: Enter passphrase for Intermediate CA private key${NC}"
echo -e "${BLUE}    WHY EXTENSIONS? They specify key usage, authentication, and hostname validation${NC}"
echo ""
openssl x509 -req -in output/client/client.csr -CA output/intermediate/intermediate.crt -CAkey output/intermediate/intermediate.key \
    -CAcreateserial -out output/client/client.crt -days 365 -sha256 \
    -extfile client.conf -extensions v3_client_req

echo -e "${GREEN}✓ Client Certificate created: client.crt (365 days)${NC}"
echo ""

# ==================== CERTIFICATE CHAIN CONVERSION ====================
echo -e "${BOLD}### STEP 2: Creating Full Certificate Chain and Converting to PKCS#12 ###${NC}"
echo ""

echo ">>> Creating certificate chain (concatenating client cert + intermediate cert)"
cat output/client/client.crt output/intermediate/intermediate.crt > output/fullchain_client.crt

echo ">>> Converting Client Certificate to PKCS#12 format (.p12)"
echo -e "${BLUE}    NOTE: Enter NEW passphrase for PKCS#12 file (different from private key passphrases)${NC}"
echo ""
openssl pkcs12 -export -in output/fullchain_client.crt -inkey output/client/client.key \
    -name "client" -out output/fullchain_client.p12

echo -e "${GREEN}✓ Certificate chain conversion complete!${NC}"
echo ""

# ==================== IMPORTING ROOT CA INTO TRUSTSTORE ====================
echo -e "${BOLD}### STEP 3: Importing Root CA into Truststore ###${NC}"
echo ""
echo -e "${BLUE}    NOTE: At least 6 characters for truststore passphrase${NC}"
echo ""

# Import the Root CA into a new truststore file
keytool -import -trustcacerts -alias rootca -file output/root/rootCA.crt -keystore output/truststore.p12 -storetype PKCS12

echo ""

echo ""
echo -e "${BOLD}1. Import 'output/fullchain_client.p12' to your computer by double-clicking on it.${NC}"
echo -e "${BOLD}   You may need to import the same in your browser${NC}"
echo -e "${BOLD}   E.g. for Brave browser - brave://certificate-manager/clientcerts/platformclientcerts${NC}"

echo ""
echo -e "${BOLD}2. Copy 'output/truststore.p12' to your application's truststore location 'src/main/resources/trust/truststore.p12'${NC}"

echo ""
echo -e "${BOLD}3. Update 'src/main/resources/application.yaml' property 'server.ssl.trust-store-password' to your TRUSTSTORE EXPORT password${NC}"

echo ""
echo -e "${BOLD}4. Run the application:${NC}"
echo -e "${BLUE}    cd ..${NC}"
echo -e "${BLUE}    ./mvnw spring-boot:run${NC}"
echo -e "${BLUE}    Access the application at https://localhost:8443${NC}"
echo ""
