Run the install script to install AWS CLI
Dependencies are Python...

Make an S3 user and install CREDS into the comand line by
running the "aws configure" command.

* Rotate your creds every 6-12 months

$ aws configure
  AWS Access Key ID [None]: <YOUR KEY ID HERE>
  AWS Secret Access Key [None]:<YOUR SECRET HERE>
  Default region name [None]: us-east-1
  Default output format [None]: json

You should be able to list your buckets with "aws s3 ls"
Make sure that only your account can access your credentals: chmod 600
  AWS config is stored at ~/.aws/


  You will also need to install the jq json parser
  The install directions are handled by the install script
  The script will need sudo access to copy the binary file to the user bin.
  https://stedolan.github.io/jq/download/



  # Please use the "S3-upload-download" IAM policy for uploading and downloadin files
  # This policy limits acess to S3 buckets named with the "seckur" prefix,  "sekur*"
  # Access is also limited to "Get" and "Put" commands

  # This file uses the AWS CLI interface.  Please refer to the read me and install file
  # RESOURCES
  # S3
  # http://docs.aws.amazon.com/cli/latest/reference/s3/
  # http://docs.aws.amazon.com/cli/latest/reference/s3/cp.html
  # SQS
  # http://docs.aws.amazon.com/cli/latest/reference/sqs/send-message.html
  # IAM need SQS and S3 Permitions
