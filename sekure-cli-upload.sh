#!/bin/bash
source ./config.sh

main(){
  echo "Getting ready to archive...."
  recurse "${uploadDir}"
  # moveFiles "${uploadDir}"
  echo "Moving your files out of upload...."
  echo "Done"
}

upload(){
  filePath=$1
  awsPath=$2
  aws s3 cp "${filePath}" "s3://${bucketName}/${awsPath}" --sse
}

recurse() {
 for i in "$1"/*;do
    if [ -d "$i" ];then
        recurse "$i"
    elif [ -f "$i"  ]; then
      size=$(wc -c <"$i")
      if [[ $size < $maxSize ]]; then
        fileHash=$(date +"%Y-%m-%d-%H-%M-%S")
        timeStamp=$(date +"%Y-%m-%d %H:%M:%S")
        s3Path=$(echo "${i##*/}-${fileHash}")
        # upload "${i}" "${s3Path}"
        updateDB "${i}" "${s3Path}" "${timeStamp}" "${size}"
        # sqsupload "${i}" "${awsPath}" "${timeStamp}" "${size}"
      else
        echo "Your file is larger then ${maxSize} bytes!"
      fi
    fi
 done
}

updateDB(){
    filePath=$1
    fileName=$(echo "${filePath##*/}")
    s3Path="${2}"
    timeStamp=$3
    localDir=$(echo "${filePath}" |  sed "s#$uploadDir##")
    localDir=$(dirname "${localDir}")
    mime=$(file -b "${filePath}")
    size=$4
    header=$(printf '"authorization: tester",  "folder: %s", "name: %s", "mime: %s", "size: %s", "created: %s", "s3: %s"' "$localDir" "$fileName" "$mime" "$size" "$timeStamp" "$s3Path")
    # json=$(printf '{"key1":"%s", "key2":"%s", "key3":"%s", "key4":"%s", "key5":"%s", "key6":"%s"}' "$localDir" "$fileName" "$mime" "$size" "$timeStamp" "$s3Path")

    S3KEY=""
    S3SECRET="" # pass these in
    signature=$(echo -en "${string}" | openssl sha1 -hmac "${S3SECRET}" -binary | base64)
    auth=$($S3KEY, $S3SECRET $region, 'execute-api')

    json=$(printf '{"folder":"%s", "name":"%s", "mime":"%s", "size":"%s", "created":"%s", "s3":"%s"}' "$localDir" "$fileName" "$mime" "$size" "$timeStamp" "$s3Path")
    echo $json

    #
    # curl -X POST -i -H "Content-type: application/json" -H "Authorization: $auth"  -X POST https://k4tq4t50u0.execute-api.us-east-1.amazonaws.com/prod/upload -d $json
    # curl --header $header https://k4tq4t50u0.execute-api.us-east-1.amazonaws.com/prod/upload



  aws lambda invoke \
--function-name upload-lambda \
--region $region \
--log-type Tail \
--payload $json \
--profile adminscript \
outputfile.txt
}


moveFiles(){
  target=$1
  timeStamp=$(date +"%Y-%m-%d %H:%M:%S")
  archivedDir=$(echo "${archivedDir}-${timeStamp}")
  mkdir "${archivedDir}"
  mv  "${target}" "${archivedDir}"
  mkdir "${target}"
}


main
