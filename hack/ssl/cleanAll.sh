#/bin/bash
rm -rf ca certs crl es-ops es-logging fluentd-elasticsearch kibana kibana-ops truststore root-ca.p12 ../elasticsearch.yml
oc delete secrets elasticsearch elasticsearch-config elasticsearch-ops fluentd kibana kibana-ops
