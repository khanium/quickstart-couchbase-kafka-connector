#!/bin/bash
echo "deleting couchbase data..."
rm -Rf db/couchbase/*
echo "deleting Kafka & zookeeper data..."
rm -Rf data/kafka-data/*
rm -Rf data/zk-data/*
rm -Rf data/zk-txn-logs/*
echo "clean up completed successfully"
