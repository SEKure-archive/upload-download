#!/bin/bash

bucket="sekure-archive"
s3Key=""
s3Secret="" # pass these in

currentPath="${PWD}"


function uploadS3() {
  # path=$1
  # file=$2
  fullPath="${1}"
  awsPath=`echo "${fullPath}" | sed 's|'"${currentPath}/"'||g'` #  Escape spaces
  # awsPath=`echo $path | sed 's/^.*\.//'`
  echo "${awsPath}"

  #objectName=${path}${file}
  resource="/${bucket}/${awsPath}"
  contentType="text/plain"    #Change later
  dateValue=$(date -R)
  stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
  signature=$(echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64)
  curl -v -i -X PUT -T "${fullPath}" \
            -H "Host: ${bucket}.s3.amazonaws.com" \
            -H "Date: ${dateValue}" \
            -H "Content-Type: ${contentType}" \
            -H "Authorization: AWS ${s3Key}:${signature}" \
            https://${bucket}.s3.amazonaws.com/${awsPath}
}

# Gets directory
#echo $(dirname "${1}") | cut -d '.' -f 1

#echo "file: ${i##*/}"
#d="/"
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
    uploadS3  "${i}"

    fi
 done
}

recurse "${currentPath}"
