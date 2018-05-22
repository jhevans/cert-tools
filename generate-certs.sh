#!/usr/bin/env bash
set -e

export ROOT_CA
export OUTPUT_DIR=/certs/generated
export country=GB
export state=London
export locality=London
export organization=TestOrg
export organizationalunit=RootCA
export root_commonname=rootca.local
export intermediate_commonname=intermediateca.local
export server_commonname=server.local
export client_commonname=client.local
export email=foo@example.com

# This script will create all the certificates needed to set up mutual auth, including a self-signed root CA certificate

# Generate Root, Intermediate CA and server, client keys
# Note: the output file here actually contains the private and public keys, run the following to extract the public key:
# openssl rsa -in rootCA.key -outform PEM -pubout -out publicRoot.pem
# and private key:
openssl rsa -in rootCA.key -outform PEM -out privateRoot.pem
openssl genrsa -out ${OUTPUT_DIR}/rootCA.key 2048
openssl genrsa -out ${OUTPUT_DIR}/intermediateCA.key 2048
openssl genrsa -out ${OUTPUT_DIR}/server.key 2048
openssl genrsa -out ${OUTPUT_DIR}/client.key 2048


# Generate self-signed Root CA certificate
openssl req -x509 -new -key ${OUTPUT_DIR}/rootCA.key -nodes -days 365 -out ${OUTPUT_DIR}/rootCA.crt \
  -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$root_commonname/emailAddress=$email" \
  -config openssl.cnf
echo "Generated root cert"
openssl x509 -in ${OUTPUT_DIR}/rootCA.crt -text -noout

# Generate signing requests for intermediate CA, server client
openssl req -new -key ${OUTPUT_DIR}/intermediateCA.key -out ${OUTPUT_DIR}/intermediateCA.csr \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$intermediate_commonname/emailAddress=$email" \
-config openssl.cnf
openssl req -new -key ${OUTPUT_DIR}/server.key -out ${OUTPUT_DIR}/server.csr \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$server_commonname/emailAddress=$email" \
-config openssl.cnf
openssl req -new -key ${OUTPUT_DIR}/client.key -out ${OUTPUT_DIR}/client.csr \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$client_commonname/emailAddress=$email" \
-config openssl.cnf

# Generate certificates from csrs
openssl x509 -req -in ${OUTPUT_DIR}/intermediateCA.csr -CA ${OUTPUT_DIR}/rootCA.crt -CAkey ${OUTPUT_DIR}/rootCA.key -CAcreateserial -out ${OUTPUT_DIR}/intermediateCA.crt -days 365 -sha256
openssl x509 -req -in ${OUTPUT_DIR}/server.csr -CA ${OUTPUT_DIR}/rootCA.crt -CAkey ${OUTPUT_DIR}/rootCA.key -CAcreateserial -out ${OUTPUT_DIR}/server.crt -days 365 -sha256
openssl x509 -req -in ${OUTPUT_DIR}/client.csr -CA ${OUTPUT_DIR}/rootCA.crt -CAkey ${OUTPUT_DIR}/rootCA.key -CAcreateserial -out ${OUTPUT_DIR}/client.crt -days 365 -sha256


# Other useful stuff:
# Print details of cert
# openssl x509 -in ${OUTPUT_DIR}/intermediate_cert.crt -text -noout

# # Generate Diffie-Hellman group
# # openssl dhparam -out ${OUTPUT_DIR}/dhparam.pem 2048 # This takes a very long time and you probably don't need it if you're just hacking about
#
# # Generate keystore
# openssl pkcs12 -export -in ${OUTPUT_DIR}/server_cert.crt -inkey ${OUTPUT_DIR}/server_key.key -out ${OUTPUT_DIR}/server_keystore.p12 -password pass:abc123
