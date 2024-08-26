#!/bin/bash

NODE_ID=$(( ${HOSTNAME:13} + 1000 ))
SERVER_REFERENCE_CONF=/opt/kafka/conf/server-reference.conf
SERVER_CONF=/opt/kafka/conf/server.conf
CLUSTER_ID="OKbXWnLxQI-iFjS3AFuIzw"
export KAFKA_HEAP_OPTS="-Xmx256M -Xms256M"
sed -e "s/node.id=.*/node.id=$NODE_ID/" \
    -e "s/ENVIRONMENT/$ENVIRONMENT/g" \
    $SERVER_REFERENCE_CONF > $SERVER_CONF
/usr/local/lib/kafka/bin/kafka-storage.sh format -t $CLUSTER_ID -c $SERVER_CONF
/usr/local/lib/kafka/bin/kafka-server-start.sh $SERVER_CONF
