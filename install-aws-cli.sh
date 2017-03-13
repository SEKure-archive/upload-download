#!/bin/bash

#Linux Install
#Documentation: http://docs.aws.amazon.com/cli/latest/userguide/awscli-install-bundle.html

#INSTALL PYTHON V2 or greater
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"$
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
aws --version
mkdir "${PWD}/upload/"

#Recieve Files needs jq for parsing json formate in bash
#  Install jq
wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
chmod +x ./jq
sudo cp jq /usr/bin
