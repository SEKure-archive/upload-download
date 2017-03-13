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
parseQueueSize=".Attributes.ApproximateNumberOfMessages"
maxMessages=10  #  --max-number-of-messages

####################  AWS ###############################

# Make Dir
timeStamp=$(date +"%Y-%m-%d-%H-%M-%S")
restoreDir=$(echo "${restoreDir}-${timeStamp}")
mkdir "${restoreDir}"

# Get Queue Size
query=$(aws sqs get-queue-attributes --queue-url  "${sqsUrl}" --attribute-names ApproximateNumberOfMessages)
qsize=$(echo "${query}" | jq --raw-output "${parseQueueSize}")

while [ $qsize -gt 0 ]
do
  # Get message from SQS queue and parse JSON
  message=$(aws sqs receive-message --queue-url "${sqsUrl}"  --message-attribute-names All )
  # message=$(aws sqs receive-message --queue-url "${sqsUrl}" --attribute-names All --message-attribute-names All --max-number-of-messages "${maxMessages}")
  receipt=$(echo "${message}" | jq --raw-output $parse.ReceiptHandle)
  name=$(echo "${message}" | jq --raw-output "${parseMA}".filename.StringValue)
  dir=$(echo "${message}" | jq --raw-output $parseMA.directory.StringValue)
  s3path=$(echo "${message}" | jq --raw-output $parseMA.s3path.StringValue)

  Delete Message
  aws sqs delete-message --queue-url "${sqsUrl}" --receipt-handle "${receipt}"

  path=$(echo "${restoreDir}${dir}/${name}")
  aws s3 cp  "s3://${bucketName}/${s3path}" "${path}"

  echo "Retored: ${path}"
  let "qsize--" #counter

# If zero check to see if new messages have been added
  if [ $qsize -le 0 ]; then
    query=$(aws sqs get-queue-attributes --queue-url  "${sqsUrl}" --attribute-names ApproximateNumberOfMessages)
    qsize=$(echo "${query}" | jq --raw-output "${parseQueueSize}")
  fi

done
echo "Done"
