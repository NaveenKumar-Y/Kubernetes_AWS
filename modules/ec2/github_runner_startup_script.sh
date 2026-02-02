#!/bin/bash
set -e

GH_PAT=$(aws ssm get-parameter \
  --name "/github/runner/pat" \
  --with-decryption \
  --query 'Parameter.Value' \
  --output text \
  --region us-east-1)


########### for GitHub Actions Runner Setup for individual repo ###########
# OWNER="NaveenKumar-Y"
# REPO="${github_repo}"

# REG_TOKEN=$(
#   curl -sL \
#     -X POST \
#     -H "Accept: application/vnd.github+json" \
#     -H "Authorization: Bearer $GH_PAT" \
#     -H "X-GitHub-Api-Version: 2022-11-28" \
#     "https://api.github.com/repos/$OWNER/$REPO/actions/runners/registration-token" |
#   jq -r '.token'
# )
##############################################################################33


########### for GitHub Actions Runner Setup for Organization level ###########
# Define the GitHub Organization name
ORG="${GITHUB_ORG}"


REG_TOKEN=$(
  curl -sL \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GH_PAT" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/orgs/$ORG/actions/runners/registration-token" |
  jq -r '.token'
)

# You can now use $REG_TOKEN in your runner configuration script (e.g., ./config.sh)
# echo "Organization Registration Token: $REG_TOKEN"

################################333

# Install ICU as root
yum install -y libicu

# Create runner directory owned by ec2-user
sudo -u ec2-user mkdir -p /home/ec2-user/actions-runner && cd /home/ec2-user/actions-runner

curl -o runner.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-linux-x64-2.317.0.tar.gz
chmod 644 runner.tar.gz
chown ec2-user:ec2-user runner.tar.gz

# Extract as ec2-user
sudo -u ec2-user tar xzf runner.tar.gz --strip-components=1
# sudo -u ec2-user rm runner.tar.gz

# Fix ownership
chown -R ec2-user:ec2-user /home/ec2-user/actions-runner

# Configure as ec2-user
sudo -u ec2-user ./config.sh \
  --url "${GH_ORG_URL}" \
  --token "$REG_TOKEN" \
  --unattended \
  --labels ec2-terraform-runner \
  --runasservice

sudo ./svc.sh install 
sudo ./svc.sh start

sleep 10

echo "install helm"

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh


