# License

Copyright 2017 Google Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# Purpose
The purpose of this demo is to show how simple it is to create a serverless and scalable architecture using GCP.
The script will guide you through the creation of all the GCP components needed to:
- ingest data from a device
- process data
- analyse data

# Requirements:
- a GCP account (https://cloud.google.com/free/)
- a GCP project (https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project)
- gcloud (https://cloud.google.com/sdk/gcloud/#what_is_gcloud)
- JDK and maven

# How to run the demo:

### Set parameters
Export yout project id in GCLOUD_PROJECT, then:
```shell
. set_params.sh
```

### Login into gcloud
```shell
gcloud auth login
```

### Set the projectID in gcloud
```shell
gcloud config set project $projectID
```

### Create the temp location in CloudStorage
```shell
gsutil mb gs://$bucket/ && touch a-file && echo "temp" > a-file && gsutil cp a-file gs://$tempLocation && rm a-file
```

### Perform local operations in a sandbox
```shell
mkdir -p $home
cd $home
```

### Create pubsub topic
```shell
gcloud beta pubsub topics create $topic
```

### Configure IAM account for Cloud IoT

In the [IAM section of the Cloud Console](https://console.cloud.google.com/iam-admin/iam): add the special account cloud-iot@system.gserviceaccount.com with the role Publisher to the PubSub topic (it is needed to allow Cloud IoT to push into PubSub messages received on the MQTT broker). Alternatevely use the gcloud command.
```shell
gcloud projects add-iam-policy-binding $projectID \
--member serviceAccount:cloud-iot@system.gserviceaccount.com --role roles/pubsub.publisher
```

### Create CloudIoT instance
```shell
gcloud beta iot registries create $registryName \
    --project=$projectID \
    --region=$iotzone \
    --event-pubsub-topic=$topicFullName
```

### Clone client code
```shell
git clone https://github.com/aulisse/java-docs-samples/
```

### Generate keys to be used for securing device/cloud connectivity
```shell
./java-docs-samples/iot/api-client/generate_keys.sh
```

### Register a device
```shell
gcloud beta iot devices create $deviceName \
  --project=$projectID \
  --region=$iotzone \
  --registry=$registryName \
  --public-key path=rsa_cert.pem,type=rs256
```

### Create BigQuery DataSet & Table
```shell
bq mk $dataset
bq mk -t $table message:string,city:string,temperature:float,hour:integer
```

### Run pipeline
```shell
curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $(gcloud auth print-access-token)" https://dataflow.googleapis.com/v1b3/projects/$projectID/templates:launch?gcsPath=gs://dataflow-templates/pubsub-to-bigquery/template_file -d  '{"jobName":"'$jobName'","parameters":{"topic":"'$topicFullName'","table":"'$table'"},"environment":{"tempLocation":"gs://'$tempLocation'","maxWorkers":"'$maxWorkers'","zone":"'$dataflowzone'"}}'
```

### Move to Java client folder
```shell
cd $home/java-docs-samples/iot/api-client/mqtt_example
```

### Modify code:
* MqttExample.java, line 159 
```java
String payload = String.format("{\"message\":\"%s/%s-message-%d\",\"city\":\"Milan\",\"temperature\":\""+(20+new java.util.Random().nextDouble()*5)+"\",\"hour\":\""+(new java.util.Random().nextInt(24))+"\"}", options.registryId, options.deviceId, i);
```
* MqttExample.java, line 172 
```java
sleep 300 ms 
```
* MqttExampleOptions.java, line 32
```java
numMessages = 1_000
```

Feel free to change values for payload, sleep and numMessages but do not modify the json structure of the payload.

### Clean and compile 
```shell
mvn clean compile
```

### Run MQTT client
```shell
mvn exec:java -Dexec.mainClass="com.google.cloud.iot.examples.MqttExample" -Dexec.args="-project_id='$projectID' -registry_id='$registryName' -device_id='$deviceName' -private_key_file=../../../../rsa_private_pkcs8 -algorithm=RS256"
```

## Run queries during the ingestion
```shell
bq query "select count(*) as count FROM [$table]"
bq query "SELECT hour, avg(temperature) as avg_temp FROM [$table] group by hour order by hour asc"
```
If the Java client did not finish yet, run the queries in another shell window (run set_params.sh before running the queries). Alternatevely, you can run the queries in BigQuery console and then click "Save to Google Sheets" (where you might want to leverage the Explore feature - bottom right corner of the sheet - to generate automatically a chart)

# How to shut down the demo:
Run set_params.sh and clean.sh to free up resources
