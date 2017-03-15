#!/bin/bash
source ./config.sh

uploadDir=$(echo "${restoreLocation}/upload")
archivedDir=$(echo "${restoreLocation}/archived")

sqsupload(){
  filePath=$1
  fileName=$(echo "${filePath##*/}")
  s3Path="${2}"
  timeStamp=$3
  localDir=$(echo "${filePath}" |  sed "s#$uploadDir##")
  localDir=$(dirname "${localDir}")
  mime=$(file -b "${filePath}")
  size=$4

message="Uploading File" # Text Required.

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
  }' "$fileName" "$localDir" "$s3Path" "$timeStamp" "$mime" "$size")
aws sqs send-message --queue-url "${sqsUrl}${sqsUpload}"    --message-body "${message}" --message-attributes "${json}"
}

upload(){
  filePath=$1
  awsPath=$2
  aws s3 cp "${filePath}" "s3://${bucketName}/${awsPath}" --sse
}

moveFiles(){
  target=$1
  timeStamp=$(date +"%Y-%m-%d-%H-%M-%S")
  archivedDir=$(echo "${archivedDir}-${timeStamp}")
  mkdir "${archivedDir}"
  mv  "${target}" "${archivedDir}"
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
        sqsupload "${i}" "${awsPath}" "${timeStamp}" "${size}"
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
