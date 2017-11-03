. set_params.sh

#delete Cloud IoT
gcloud beta iot devices delete $deviceName --region=$iotzone --registry=$registryName
gcloud beta iot registries delete $registryName --region=$iotzone

#delete pubsub topic
gcloud beta pubsub topics delete $topic

#cancel dataflow job
gcloud dataflow jobs list | grep Running
job_id=$(gcloud dataflow jobs list | grep Running | awk '{print $1;}')
gcloud dataflow jobs cancel $job_id --region=$dataflowzone

#delete BigQuery table
bq rm $table
