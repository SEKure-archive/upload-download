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
