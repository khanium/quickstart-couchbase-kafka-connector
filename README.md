# quickstart-couchbase-kafka-connector
![local overview](doc/assets/local.png)
Docker Compose quick development starting kit for deploying Couchbase + Confluent Kafka Platform and Distributed Couchbase Kafka Connector

## Quick start with Kafka Confluent and local Couchbase instance

![local overview](doc/assets/local.png)

```
docker-compose up
```

Then, verify:

* Couchbase is UP: [http://localhost:8091](http://localhost:8091) user: `Administrator` password: `password`
* **Historical** bucket
* sink-user user with application role on Historical bucket
* Checking Kafka Confluent platform is UP: [http://localhost:9021](http://localhost:9021)
* `raw-events` topic
* Couchbase-Sink-Connector sink connector running


## Quick start with Kafka Confluent and Couchbase Capella

![local overview](doc/assets/capella.png)

### Pre-requisites

1. Create a Capella Cluster and the target Bucket/Scope/Collection 
2. Create a Capella Access User with write and read permissions in that collection
3. Allow the ip address connectivity between your local environment and Capella cluster
4. Download the Capella cluster `couchbase.pem` certificate into the `./cert` folder

### Configuring Capella connection credentials into the connector

   1. Mapping `/cert` folder into the connector container volume `/data/cert` folder

```
  connect:       
    …
    volumes:
      - $PWD/data:/data
      - $PWD/cert:/data/cert
```

   2. Connect to Couchbase Capella using Secure connections and credentials properties

        - `couchbase.seed.nodes`
        - `couchbase.enable.tls`
        - `couchbase.trust.certificate.path`
        - `couchbase.enable.hostname.verification` 

```
  connect:
    …
    command:
        …
        echo -e "\n--\n+> Creating Couchbase Sink Connector"
        curl -s -X PUT -H  "Content-Type:application/json" http://localhost:8083/connectors/sink-couchbase-01/config \
            -d '{    
                  …
                  "topics": "raw-events",
                  "couchbase.seed.nodes": "couchbases://cb.bkfkly8znvcg2vtp.cloud.couchbase.com",
                  "couchbase.bootstrap.timeout": "20s",
                  "couchbase.bucket": "demo",
                  "couchbase.username": "myuser",
                  "couchbase.password": "Passw0rd!",
                  "couchbase.enable.hostname.verification": "false",
                  "couchbase.enable.tls": "true",
                  "couchbase.trust.certificate.path": "/data/cert/couchbase.pem",
                  …
        }'
        …
```

   3. Optional - you can skip the local couchbase container creation. If you want to remove/comment this couchbase image do not forget to remove it also from the dependencies from the connect container.  

## Encoders/Decoders

When working with encoded messages, the consumer must use the same schema when decoding a message that the producer used when encoding it. This could lead to difficulties in coordinating which schema was used for a given message.

To solve this problem, Kafka offers the Schema Registry, which allows you to specify the schema used to identify which schema was used for a message. The producer embeds a schema ID into the message itself, which the consumer can then look up in the registry and retrieve the exact scheme.

![Schema Registry](doc/assets/schema-registry.png)


### Ingesting Json Documents


### Ingesting Avro Data

When working with encoded messages, the consumer must use the same schema when decoding a message that the producer used when encoding it. This could lead to difficulties in coordinating which schema was used for a given message.

To solve this problem, Kafka offers the Schema Registry, which allows you to specify the schema used to identify which schema was used for a message. The producer embeds a schema ID into the message itself, which the consumer can then look up in the registry and retrieve the exact scheme.

![Schema Registry](doc/assets/schema-registry.png)


#### Kafka Avro Console Producer
 Writing a test application just to send messages to the cluster and display the results would be tedious. It’s much easier to hop on the terminal and see what’s going on interactively. Let’s imagine you have deployed an Apache cluster and are using Avro to serialize data and lighten network overhead. How can we check that our Avro setup works as expected?

 First, let’s send the message using the Kafka console Avro producer.

```console
docker exec -it schema-registry /usr/bin/kafka-avro-console-producer \
  --bootstrap-server broker:29092 \
  --topic raw-events \
  --property value.schema='{"type":"record","name":"random_record","fields":[{"name":"hello","type":"string"}]}'
```
Then introduce the json document to be ingested, one per line as many you want and to exit push `Ctrl+C`: 

```console
{"hello": "world"}
```

You can verify the created document in your Couchbase Cluster:

![Ingested Couchbase Document](doc/assets/ingestion.png)

#### Java Random AVRO Generator Application Sample
  You can find a java random AVRO generator producer in the github [https://github.com/couchbaselabs/springboot-kafka-avro-producer](https://github.com/couchbaselabs/springboot-kafka-avro-producer) repository. By default, the AVRO Kafka Producer demo is using `src/main/resources/avro-schemas/OrderValue.avsc` avro schema to produce 20K documents into the Kafka localhost `raw-events` topic.

```console
mvn spring-boot:run -Dspring-boot.run.arguments=-s=OrderValue
```

##### Troubleshooting

Note: Use a different kafka topic than our previous example. Alternatively, restart & cleanup the environment or schema registry for raw-events topic. By default, your topic matches with a single schema. If you run this example right after the kafka avro console producer you can see the following error:

```
Caused by: org.apache.kafka.common.errors.InvalidConfigurationException: Schema being registered is incompatible with an earlier schema for subject "raw-events-value", details: [{errorType:'NAME_MISMATCH', description:'The name of the schema has changed (path '/name')', additionalInfo:'expected: random_record'}, {errorType:'READER_FIELD_MISSING_DEFAULT_VALUE', description:'The field 'orderID' at path '/fields/0' in the new schema has no default value and is missing in the old schema', additionalInfo:'orderID'}, {errorType:'TYPE_MISMATCH', description:'The type (path '/fields/1/type') of a field in the new schema does not match with the old schema', additionalInfo:'reader type: ENUM not compatible with writer type: RECORD'}, {errorType:'TYPE_MISMATCH', description:'The type (path '/fields/3/type') of a field in the new schema does not match with the old schema', additionalInfo:'reader type: ENUM not compatible with writer type: RECORD'}, {errorType:'READER_FIELD_MISSING_DEFAULT_VALUE', description:'The field 'isOrderPaid' at path '/fields/4' in the new schema has no default value and is missing in the old schema', additionalInfo:'isOrderPaid'}, {errorType:'READER_FIELD_MISSING_DEFAULT_VALUE', description:'The field 'totalCost' at path '/fields/5' in the new schema has no default value and is missing in the old schema', additionalInfo:'totalCost'}, {errorType:'READER_FIELD_MISSING_DEFAULT_VALUE', description:'The field 'orderItems' at path '/fields/6' in the new schema has no default value and is missing in the old schema', additionalInfo:'orderItems'}, {oldSchemaVersion: 1}, {oldSchema: '{"type":"record","name":"random_record","fields":[{"name":"hello","type":"string"}]}'}, {compatibility: 'BACKWARD'}]; error code: 409
```
