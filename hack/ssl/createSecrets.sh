#! /bin/bash

# create elasticsearch cert secret
oc create secret generic elasticsearch --from-file=$PWD/es-logging/key --from-file=$PWD/truststore

# create elasticsearch config secret
oc create secret generic elasticsearch-config --from-file=$PWD/../elasticsearch.yml

# create elasticsearch ops cert secret
oc create secret generic elasticsearch-ops --from-file=$PWD/es-ops/key --from-file=$PWD/truststore

# create fluentd cert secret
oc create secret generic fluentd --from-file=$PWD/fluentd-elasticsearch/cert --from-file=$PWD/fluentd-elasticsearch/key --from-file=$PWD/ca/ca

# create kibana cert secret
oc create secret generic kibana --from-file=$PWD/kibana/cert --from-file=$PWD/kibana/key --from-file=$PWD/ca/ca

# create kibana ops cert secret
oc create secret generic kibana-ops --from-file=$PWD/kibana-ops/cert --from-file=$PWD/kibana-ops/key --from-file=$PWD/ca/ca


