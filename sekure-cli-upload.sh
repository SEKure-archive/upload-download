#!/bin/bash

# Please use the "S3-upload-download" IAM policy for uploading and downloadin files
# This policy limits acess to S3 buckets named with the "seckur" prefix,  "sekur*"
# Access is also limited to "Get" and "Put" commands

# This file uses the AWS CLI interface.  Please refer to the read me and install file

####################  AWS ###############################
# bucketName="${$1}"
bucketName="sekure-archive"
sqsUrl="https://sqs.us-east-1.amazonaws.com/373886653085/upload"
uploadDir=$(echo "${PWD}/upload")
maxSize=90000

####################  AWS ###############################
# RESOURCES
# S3
# http://docs.aws.amazon.com/cli/latest/reference/s3/
# http://docs.aws.amazon.com/cli/latest/reference/s3/cp.html
# SQS
# http://docs.aws.amazon.com/cli/latest/reference/sqs/send-message.html

# IAM need SQS and S3 Permitions

upload(){
  filePath=$1
  awsPath=$2
  aws s3 cp "${filePath}" "s3://${bucketName}/${awsPath}" --sse
}

sqs(){
  filePath=$1
  fileName=$(echo "${filePath##*/}")
  awsPath="${2}"
  timeStamp=$3
  localDir=$(echo "${filePath}" |  sed "s#$uploadDir##")
  localDir=$(dirname "${localDir}")
  mime=$(file -b "${filePath}")
  size=$4

# Text Required.  What to put in?
message="Uploading File"

#Message Attributes can hold 10 JSON objects
#Supports: String, Binary, Number
# AWS Documetation wrong, Must be formatted:
# --message-attributes '{ "firstAttribute":{ "DataType":"String","StringValue":"hello world" } }'
  json=$(printf '{
    "filename":{ "DataType":"String","StringValue":"%s" },
    "directory":{ "DataType":"String","StringValue":"%s" },
    "s3path":{ "DataType":"String","StringValue":"%s" },
    "time":{ "DataType":"String","StringValue":"%s" },
    "mime":{ "DataType":"String","StringValue":"%s" },
    "size":{ "DataType":"Number","StringValue":"%d" }
  }' "$fileName" "$localDir" "$awsPath" "$timeStamp" "$mime" "$size")
aws sqs send-message --queue-url "${sqsUrl}"    --message-body "${message}" --message-attributes "${json}"

}

moveFiles(){
  target=$1
  timeStamp=$(date +"%Y-%m-%d-%H-%M-%S")
  archived=$(echo "${PWD}/archived-${timeStamp}/")
  mv  "${target}" "${archived}"
  mkdir "${target}"
}



recurse() {
 for i in "$1"/*;do
    if [ -d "$i" ];then
        recurse "$i"
    elif [ -f "$i"  ]; then
      size=$(wc -c <"$i")
      if [[ $size < $maxSize ]]; then
        timeStamp=$(date +"%Y-%m-%d-%H-%M-%S")
        awsPath=$(echo "${i##*/}-${timeStamp}")
        upload "${i}" "${awsPath}"
        sqs "${i}" "${awsPath}" "${timeStamp}" "${size}"
      else
        echo "Your file is larger then ${maxSize} bytes!"
      fi
    fi
 done
}

echo "Getting ready to archive...."
recurse "${uploadDir}"
moveFiles "${uploadDir}"
echo "Moving your files out of upload...."
echo "Done"
