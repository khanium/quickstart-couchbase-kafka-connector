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

