#!/bin/bash


# Documetation: https://docs.aws.amazon.com/cli/latest/reference/sqs/receive-message.html

####################  AWS ###############################
# bucketName="${$1}"
bucketName="sekure-archive"
sqsUrl="https://sqs.us-east-1.amazonaws.com/373886653085/download"
restoreDir=$(echo "${PWD}/restore")
parse=".Messages[0].MessageAttributes"
maxSize=90000

####################  AWS ###############################

message=$(aws sqs receive-message --queue-url "${sqsUrl}" --attribute-names All --message-attribute-names All --max-number-of-messages 10)
echo "message"
# echo "${message}" | jq .Messages[0].MessageAttributes.filename.StringValue
echo "${message}" | jq $parse.filename.StringValue
