# Configure the AWS Provider
provider "aws" {
  # Configuration options
  region = "us-east-1"

  # access via credentials file
  # shared_credentials_file = "~/.aws/credentials"
  # 
  # [naveen]
  # aws_access_key_id = xxx
  # aws_secret_access_key = xxx
  # ```

  # profile = "naveen"
  profile = "default"

  ###################################################
  # or
  # access directly in provider :
  # access_key = "xxxxxxxxxxxxxxxxxxxxxx"
  # secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxx"


}


###################################################
# or
# access via environment variables:

# linux
# export AWS_ACCESS_KEY_ID="xxxxxxxxxxxxxxxxxxxxx"
# export AWS_SECRET_ACCESS_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# export AWS_REGION="us-east-1"


# windows
# $AWS_ACCESS_KEY_ID="xxxxxxxxxxxxxxxxxxxxxx"
# $AWS_SECRET_ACCESS_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# $AWS_REGION="us-east-1"

