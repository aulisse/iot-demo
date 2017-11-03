projectID=$GCLOUD_PROJECT

V=41
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
