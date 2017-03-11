#!/bin/bash

bucket="sekure-archive"
s3Key=""
s3Secret="" # pass these in
encryption="x-amz-server-side-encryption: AES256"   # Server Side Encryption
#AWS RESTFUL API
#http://docs.aws.amazon.com/AmazonS3/latest/dev/SSEUsingRESTAPI.html

#Encryption.  Can configure server or client side based on your needs
#See Documentation
#https://aws.amazon.com/blogs/security/how-to-prevent-uploads-of-unencrypted-objects-to-amazon-s3/
#http://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectPUT.html



currentPath="${PWD}"


function uploadS3() {
  # path=$1
  # file=$2
  fullPath="${1}"
  #  Keeps folder structure
  # awsPath=`echo "${fullPath}" | sed 's|'"${currentPath}/"'||g'` #  Escape spaces

  now=$(date +"%m-%d-%Y-%s")
  awsPath=`echo "${fullPath##*/}-${now}"`
  echo "${awsPath}"



  objectName=${path}${file}
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
