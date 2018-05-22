#!/usr/bin/env bash
set -e

export OUTPUT_DIR=/certs/client/

# Extract private key from a pfx keystore
openssl pkcs12 -in ${OUTPUT_DIR}/${1}.pfx -nocerts -out ${OUTPUT_DIR}/client.key -nodes
# Extract cert from a pfx keystore
openssl pkcs12 -in ${OUTPUT_DIR}/${1}.pfx -nokeys -out ${OUTPUT_DIR}/cert.cert
