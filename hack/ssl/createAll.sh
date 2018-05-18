#/bin/bash
CA_PASS=$1
TS_PASS=$2
KS_PASS=$3

echo "Cleaning up old files and secrets"
rm -rf ca certs crl es-ops es-logging fluentd-elasticsearch kibana kibana-ops truststore root-ca.p12 ../elasticsearch.yml
oc delete secrets elasticsearch elasticsearch-config elasticsearch-ops fluentd kibana kibana-ops

echo "generating ca"
./gen_root_ca.sh $CA_PASS $TS_PASS 

echo "geberating pem certs"
for i in fluentd-elasticsearch kibana kibana-ops; do ./generatePEMCerts.sh $i $KS_PASS $CA_PASS; done

echo "generating jks certs"
for i in es-logging es-ops ; do ./generateJKSChain.sh $i $KS_PASS $CA_PASS ; done

echo "generating elasticsearch config" 
sed -i "s/KSPASS/$KS_PASS/g" ../elasticsearch.yml.template > ../elasticsearch.yml
sed -i "s/TSPASS/$TS_PASS/g" ../elasticsearch.yml.template > ../elasticsearch.yml

./createSecrets.sh
