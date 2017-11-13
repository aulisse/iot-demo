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
 
projectID=$GCLOUD_PROJECT

#if you want to run the demo multiple times, just increment this variable
V=100

#sandbox location for local operations
home=~/sandbox/t$V

flowName=run$V

bucket=$projectID-demo
tempLocation=$bucket/temp/
dataset=Demo
jobName=$flowName
maxWorkers=10
table=$projectID:$dataset.$flowName
dataflowzone=us-central1-f
workerType=custom-4-8192

topic=$flowName
topicFullName=projects/$projectID/topics/$topic

iotzone=us-central1
deviceName=demo-rs256-device
registryName=$flowName
