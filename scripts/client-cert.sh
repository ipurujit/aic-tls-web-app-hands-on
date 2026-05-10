#!/bin/bash
# This script generates a client certificate for localhost, signed by the Intermediate CA.
# It creates a private key, CSR, signs it with the Intermediate CA,
# and converts it to PKCS#12 format for browser/client app use.

set -e
    
# ==================== CLIENT CERTIFICATE GENERATION ====================
echo -e "${GREEN}${BOLD}### STEP 1: Generating Client Certificate for localhost ###${NC}"
echo ""

echo -e "${GREEN}>>> Generating private key for Client (2048-bit RSA)${NC}"
openssl genrsa -out client.key 2048

echo ""
echo -e "${GREEN}>>> Generating Certificate Signing Request (CSR) for Client${NC}"
MSYS_NO_PATHCONV=1 openssl req -new -key client.key -out client.csr \
    -subj "/C=MK/ST=Skopje/L=Skopje/O=UKIM/OU=FINKI/CN=localhost"

echo ""
echo -e "${GREEN}>>> Signing Client Certificate with Intermediate CA${NC}"
echo -e "${BLUE}    NOTE: Enter passphrase for Intermediate CA private key${NC}"
echo -e "${BLUE}    WHY EXTENSIONS? They specify key usage, authentication, and hostname validation${NC}"
echo ""
openssl x509 -req -in client.csr -CA intermediate.crt -CAkey intermediate.key \
    -CAcreateserial -out client.crt -days 365 -sha256 \
        -extfile client.ext

echo -e "${GREEN}✓ Client Certificate created: client.crt (365 days)${NC}"
echo ""

# ==================== CERTIFICATE CHAIN CONVERSION ====================
echo -e "${BOLD}### STEP 2: Creating Full Certificate Chain and Converting to PKCS#12 ###${NC}"
echo ""

echo ">>> Creating certificate chain (concatenating server cert + intermediate cert)"
cat client.crt intermediate.crt > fullchain_client.crt

echo ">>> Converting Client Certificate to PKCS#12 format (.p12)"
echo -e "${BLUE}    NOTE: Enter NEW passphrase for PKCS#12 file (different from private key passphrases)${NC}"
echo ""
MSYS_NO_PATHCONV=1 openssl pkcs12 -export -in fullchain_client.crt -inkey client.key \
    -name "localhost" -out fullchain_client.p12

echo -e "${GREEN}✓ Certificate chain conversion complete!${NC}"

# ==================== IMPORTING ROOT CA INTO TRUSTSTORE ====================
echo -e "${BOLD}### STEP 3: Importing Root CA into Truststore ###${NC}"
echo ""
# Import the Root CA into a new truststore file
keytool -import -trustcacerts -alias rootca -file rootCA.crt -keystore truststore.p12 -storetype PKCS12

echo ""