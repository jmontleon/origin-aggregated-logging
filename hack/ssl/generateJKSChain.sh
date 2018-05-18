#!/bin/bash
set -e
NODE_NAME=$1
KS_PASS=$2
CA_PASS=$3
rm -rf $NODE_NAME
mkdir $NODE_NAME

echo Generating keystore and certificate for node $NODE_NAME

"$JAVA_HOME/bin/keytool" -genkey \
    -alias     $NODE_NAME \
    -keystore  $NODE_NAME/key \
    -keyalg    RSA \
    -keysize   2048 \
    -validity  712 \
    -keypass $KS_PASS \
    -storepass $KS_PASS \
    -dname "CN=$NODE_NAME, OU=SSL, O=Test, L=Test, C=DE" \
    -ext san=dns:$NODE_NAME,ip:10.1.1.1

echo Generating certificate signing request for node $NODE_NAME

"$JAVA_HOME/bin/keytool" -certreq \
    -alias      $NODE_NAME \
    -keystore   $NODE_NAME/key \
    -file       $NODE_NAME/$NODE_NAME.csr \
    -keyalg     rsa \
    -keypass $KS_PASS \
    -storepass $KS_PASS \
    -dname "CN=$NODE_NAME, OU=SSL, O=Test, L=Test, C=DE" \
    -ext san=dns:$NODE_NAME,ip:10.1.1.1

echo Sign certificate request with CA
openssl ca \
    -in $NODE_NAME/$NODE_NAME.csr \
    -notext \
    -out $NODE_NAME/$NODE_NAME-signed.crt \
    -config etc/signing-ca.conf \
    -extensions v3_req \
    -batch \
    -passin pass:$CA_PASS \
    -extensions server_ext \
    -keyfile ca/signing-ca/private/signing-ca.key

echo "Import back to keystore (including CA chain)"

openssl pkcs12 \
    -export \
    -out root-ca.p12 \
    -inkey ca/root-ca/private/root-ca.key \
    -in ca/root-ca.crt \
    -passin pass:$CA_PASS \
    -passout pass:$CA_PASS

"$JAVA_HOME/bin/keytool" \
    -importkeystore \
    -srckeystore root-ca.p12 \
    -srcstoretype PKCS12 \
    -keystore $NODE_NAME/key \
    -srcstorepass $CA_PASS \
    -storepass $KS_PASS \
    -noprompt \
    -alias 1 \
    -destalias root-ca

"$JAVA_HOME/bin/keytool" \
    -import \
    -file ca/signing-ca.crt \
    -keystore $NODE_NAME/key \
    -storepass $KS_PASS \
    -noprompt \
    -alias sig-ca

"$JAVA_HOME/bin/keytool" \
    -import \
    -file $NODE_NAME/$NODE_NAME-signed.crt \
    -keystore $NODE_NAME/key \
    -storepass $KS_PASS \
    -noprompt \
    -alias $NODE_NAME

rm -f $NODE_NAME/$NODE_NAME.csr
rm -f $NODE_NAME/$NODE_NAME-signed.crt
echo All done for $NODE_NAME

