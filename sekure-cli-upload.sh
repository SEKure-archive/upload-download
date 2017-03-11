#!/bin/bash

####################  AWS ###############################
# bucketName="${$1}"
bucketName="sekure-archive"

####################  AWS ###############################


upload(){
  filePath=$1
  awsPath=$2
  timeStamp=$(date +"%Y-%m-%d-%H-%M-%S")
  awsPath=$(echo "${awsPath}-${timeStamp}")

  `aws  s3 cp "${filePath}" "s3://${bucketName}/${awsPath}" --sse`

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
      d="$i/"
        recurse "$i"
    elif [[ "${i##*/}" == "sekure-"* ]]; then
        echo skip "${i##*/}"
    elif [ -f "$i" ]; then
    # uploadS3  "${d}" "${i##*/}"
    echo "${i}"
    upload "${i}" "${i##*/}"
    #uploadS3  "${i}"

    fi
 done
}

currentPath="${PWD}"
uploadDir=$(echo "${PWD}/upload/")
recurse "${uploadDir}"
# moveFiles "${uploadDir}"

# mv  "${uploadDir}" "${archived}"
