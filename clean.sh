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

#delete Cloud IoT
gcloud beta iot devices delete $deviceName --region=$iotzone --registry=$registryName
gcloud beta iot registries delete $registryName --region=$iotzone

#delete pubsub topic
gcloud beta pubsub topics delete $topic

#cancel dataflow job
gcloud dataflow jobs list | grep Running
job_id=$(gcloud dataflow jobs list | grep $flowName | awk '{print $1;}')
gcloud dataflow jobs cancel $job_id --region=$dataflowzone

#delete BigQuery table
bq rm $table
