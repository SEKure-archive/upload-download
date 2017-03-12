#!/bin/bash

####################  AWS ###############################
# bucketName="${$1}"
bucketName="sekure-archive"
sqsUrl="https://sqs.us-east-1.amazonaws.com/373886653085/upload"
uploadDir=$(echo "${PWD}/upload")

####################  AWS ###############################


upload(){
  filePath=$1
  awsPath=$2
  `aws s3 cp "${filePath}" "s3://${bucketName}/${awsPath}" --sse`
}

sqs(){
  filePath=$1
  fileName=$(echo "${filePath##*/}")
  awsPath="${2}"
  timeStamp=$3
  localDir=`echo "${filePath}" |  sed "s#$uploadDir##"`
  localDir=`dirname "${localDir}"`
  mime=`file -b ${filePath}`
  size=$(wc -c <"$filePath")

  message=`"{\"filename\" : ${fileName}, \"s3path\" : ${awsPath}, \"directory\" : '${localDir}', \"time\" : ${timeStamp}, \"mime\" : ${mime}}"`
  echo "${message}"
  `aws sqs send-message --queue-url "${sqsUrl}"    --message-body "{\"filename\" : ${fileName}, \"s3path\" : ${awsPath}, \"directory\" : '${localDir}', \"time\" : ${timeStamp}, \"mime\" : ${mime}}"`
  # `aws sqs send-message --queue-url "${sqsUrl}" --message-body "{filename : ${filename}, s3path : ${awsPath} directory : ${localDir}, time : ${timeStamp}, mime : ${mime}  }"`
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
      awsPath=$(echo "${1##*/}-${timeStamp}")
      # upload "${i}" "${awsPath}" "${timeStamp}"
      sqs "${i}" "${awsPath}" "${timeStamp}"

    fi
 done
}


recurse "${uploadDir}"
# moveFiles "${uploadDir}"
