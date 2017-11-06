# iot-demo

/*
 * Copyright 2017 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

The purpose of this demo is to show how simple it is to create a serverless and scalable architecture using GCP.
The script will guide you through the creation of all the GCP components needed to:
- ingest data from a device
- process data
- analyse data

Requirements:
- a GCP account (https://cloud.google.com/free/)
- a GCP project (https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project)
- gcloud (https://cloud.google.com/sdk/gcloud/#what_is_gcloud)
- JDK and maven

How to run the demo:
- set your project id in set_params.sh
- follow steps contained in file run.sh (DO NOT run the whole script, execute instructions step-by-step and read comments)

How to shut down the demo:
- Use clean.sh to free up resources
