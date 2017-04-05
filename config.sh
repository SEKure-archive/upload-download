#!/bin/bash
#################  File Location ############################
maxSize=90000  #Max size of file in bytes
restoreLocation=$(echo "${PWD}/files")
uploadDir=$(echo "${restoreLocation}/upload")
archivedDir=$(echo "${restoreLocation}/archived")
####################  AWS ###############################
bucketName="sekure-archive"
region="us-east-1"
lambda="upload-lambda"
sqsUrl="https://sqs.us-east-1.amazonaws.com/373886653085/"
sqsDownload="download"  #queue name
####################  AWS ###############################
