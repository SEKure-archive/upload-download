#!/bin/bash


# Documetation: https://docs.aws.amazon.com/cli/latest/reference/sqs/receive-message.html

####################  AWS ###############################
# bucketName="${$1}"
bucketName="sekure-archive"
# sqsUrl="https://sqs.us-east-1.amazonaws.com/373886653085/download"
sqsUrl="https://sqs.us-east-1.amazonaws.com/373886653085/upload"
restoreDir=$(echo "${PWD}/restore")
parse=".Messages[0]"
parseMA=$(echo "${parse}.MessageAttributes")
maxMessages=10  #  --max-number-of-messages

####################  AWS ###############################

timeStamp=$(date +"%Y-%m-%d-%H-%M-%S")
restoreDir=$(echo "${restoreDir}-${timeStamp}")
mkdir "${restoreDir}"


# Get message from SQS queue and parse JSON
message=$(aws sqs receive-message --queue-url "${sqsUrl}" --attribute-names All --message-attribute-names All --max-number-of-messages "${maxMessages}")
receipt=$(echo "${message}" | jq --raw-output $parse.ReceiptHandle)
name=$(echo "${message}" | jq --raw-output "${parseMA}".filename.StringValue)
dir=$(echo "${message}" | jq --raw-output $parseMA.directory.StringValue)
s3path=$(echo "${message}" | jq --raw-output $parseMA.s3path.StringValue)

# Delete Message
aws sqs delete-message --queue-url "${sqsUrl}" --receipt-handle "${receipt}"


path=$(echo "${restoreDir}${dir}/${name}")

aws s3 cp  "s3://${bucketName}/${s3path}" "${path}"


echo "name"
echo "$name"

echo "dir"
echo "$dir"

echo "s3path"
echo "$s3path"

echo "restoreDir"
echo "$restoreDir"
