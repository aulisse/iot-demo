#!/bin/bash

 # Copyright 2017 Google Inc.
 #
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at
 #
 #     http://www.apache.org/licenses/LICENSE-2.0
 #
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.

. set_params.sh

#login into gcloud
gcloud auth login

#set the projectID in gcloud
gcloud config set project $projectID

#create the $tempLocation in CloudStorage
gsutil mb gs://$bucket/ && touch a-file && echo "temp" > a-file && gsutil cp a-file gs://$tempLocation && rm a-file

#perform local operations in a sandbox
mkdir -p $home
cd $home

#create pubsub topic
gcloud beta pubsub topics create $topic

# in the IAM section of the Cloud Console:
# add the special account cloud-iot@system.gserviceaccount.com with the role Publisher to that PubSub topic
# It is needed to allow Cloud IoT to push into PubSub messages received on the MQTT broker.

#create CloudIoT instance
gcloud beta iot registries create $registryName \
    --project=$projectID \
    --region=$iotzone \
    --event-pubsub-topic=$topicFullName

#clone code from github
git clone https://github.com/aulisse/java-docs-samples/

#generate keys to be used for securing device/cloud connectivity
./java-docs-samples/iot/api-client/generate_keys.sh

#register a device
gcloud beta iot devices create $deviceName \
  --project=$projectID \
  --region=$iotzone \
  --registry=$registryName \
  --public-key path=rsa_cert.pem,type=rs256

#create BigQuery DataSet & Table
bq mk $dataset
bq mk -t $table message:string,city:string,temperature:float,hour:integer

#run pipeline
curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $(gcloud auth print-access-token)" https://dataflow.googleapis.com/v1b3/projects/$projectID/templates:launch?gcsPath=gs://dataflow-templates/pubsub-to-bigquery/template_file -d  '{"jobName":"'$jobName'","parameters":{"topic":"'$topicFullName'","table":"'$table'"},"environment":{"tempLocation":"gs://'$tempLocation'","maxWorkers":"'$maxWorkers'","zone":"'$dataflowzone'"}}'

#move to Java client folder
cd $home/java-docs-samples/iot/api-client/mqtt_example

# modify code:
# 1) line 159 - String payload = String.format("{\"message\":\"%s/%s-message-%d\",\"city\":\"Milan\",\"temperature\":\""+(20+new java.util.Random().nextDouble()*5)+"\",\"hour\":\""+(new java.util.Random().nextInt(24))+"\"}", options.registryId, options.deviceId, i);
# 2) line 172 - sleep 300 ms 
# 3) numMessages = 1000 in the options file

#clean and compile 
mvn clean compile

#run MQTT client
mvn exec:java -Dexec.mainClass="com.google.cloud.iot.examples.MqttExample" -Dexec.args="-project_id='$projectID' -registry_id='$registryName' -device_id='$deviceName' -private_key_file=../../../../rsa_private_pkcs8 -algorithm=RS256"

#run queries
bq query "select count(*) as count FROM [$table]"
bq query "SELECT hour, avg(temperature) as avg_temp FROM [$table] group by hour order by hour asc"