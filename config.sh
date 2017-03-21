#!/bin/bash
####################  AWS ###############################
bucketName="sekure-archive"
region="us-east-1"
sqsUrl="https://sqs.us-east-1.amazonaws.com/373886653085/"
sqsUpload="upload" #queue name
sqsDownload="download"  #queue name
restoreLocation=$(echo "${PWD}/files")
maxSize=90000  #Max size of file in bytes
ec2IP="https://52.2.133.118"
####################  AWS ###############################

# Please use the "S3-upload-download" IAM policy for uploading and downloadin files
# This policy limits acess to S3 buckets named with the "seckur" prefix,  "sekur*"
# Access is also limited to "Get" and "Put" commands

# This file uses the AWS CLI interface.  Please refer to the read me and install file
# RESOURCES
# S3
# http://docs.aws.amazon.com/cli/latest/reference/s3/
# http://docs.aws.amazon.com/cli/latest/reference/s3/cp.html
# SQS
# http://docs.aws.amazon.com/cli/latest/reference/sqs/send-message.html
# IAM need SQS and S3 Permitions
