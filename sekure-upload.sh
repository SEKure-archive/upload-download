#!/bin/bash

bucket="sekure-archive"
s3Key=""
s3Secret="" # pass these in

function uploadS3() {
  path=$1
  file=$2
  echo "${PWD}"
  fullPath=${PWD}${file}
  objectName=${path}${file}
  resource="/${bucket}/${file}"
  contentType="text/plain"    #Change later
  dateValue=$(date -R)
  stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
  signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`
  curl -v -i -X PUT -T "${objectName}" \
            -H "Host: ${bucket}.s3.amazonaws.com" \
            -H "Date: ${dateValue}" \
            -H "Content-Type: ${contentType}" \
            -H "Authorization: AWS ${s3Key}:${signature}" \
            https://${bucket}.s3.amazonaws.com/${file}
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
    elif [ -f "$i" ]; then
    uploadS3  "${d}" "${i##*/}"
        #echo "file: " "${d}""${i##*/}"
    fi
 done
}

recurse ${1}


#for file in "${1}"/***; do
  #putS3 "$path" "${file##*/}"
#  echo "$path" "${file##*/}"
#done
