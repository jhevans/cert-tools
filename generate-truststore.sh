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

keytool -import -alias ca -file ${OUTPUT_DIR}/rootCA.crt -keystore /certs/generated/truststore.jks -noprompt -storepass changeit -trustcacerts
