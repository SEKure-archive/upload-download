#!/bin/bash

####################  AWS ###############################
# bucketName="${$1}"
bucketName="sekure-archive"
sqsUrl="https://sqs.us-east-1.amazonaws.com/373886653085/upload"
uploadDir=$(echo "${PWD}/upload")

####################  AWS ###############################


upload(){
  filePath=$1
  awsPath=$(echo "${1##*/}-${2}")
  `aws s3 cp "${filePath}" "s3://${bucketName}/${awsPath}" --sse`
}

sqs(){
  filePath=$1
  echo "file name"
  echo $filePath
  fileName=$(echo "${1##*/}")
  timeStamp=$2

  dir=`echo "${filePath}" |  sed "s#$uploadDir/##"`
  echo directory
  echo $dir
  # `aws sqs send-message --queue-url "${sqsUrl}" --message-body "Information about the largest city in Any Region." `
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
    elif [ -f "$i" ]; then
      echo "${i}"
      timeStamp=$(date +"%Y-%m-%d-%H-%M-%S")
      fileName="${i##*/}"
      # upload "${i}" "${timeStamp}"
      sqs "${i}" "${timeStamp}"
    fi
 done
}



# recurse() {
#  for i in "$1"/*;do
#     if [ -d "$i" ];then
#       d="$i/"
#         recurse "{$d}"
#     # elif [[ "${i##*/}" == "sekure-"* ]]; then
#     #     echo skip "${i##*/}"
#     elif [ -f "$i" ]; then
#     # uploadS3  "${d}" "${i##*/}"
#     echo "${i}"
#     timeStamp=$(date +"%Y-%m-%d-%H-%M-%S")
#     awsPath="${i##*/}"
#     # upload "${i}" "${awsPath}"
#     sqs "${i}" "${awsPath}"
#
#     fi
#  done
# }

recurse "${uploadDir}"
# moveFiles "${uploadDir}"

# mv  "${uploadDir}" "${archived}"
