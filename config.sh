#!/bin/bash
#################  File Location ############################
restoreLocation=$(echo "${PWD}/files")
uploadDir=$(echo "${restoreLocation}/upload")
archivedDir=$(echo "${restoreLocation}/archived")
####################  AWS ###############################
bucketName="sekure-archive"
region="us-east-1"
sqsUrl="https://sqs.us-east-1.amazonaws.com/373886653085/"
sqsDownload="download"  #queue name
maxSize=90000  #Max size of file in bytes
ec2IP="https://52.2.133.118"
####################  AWS ###############################
