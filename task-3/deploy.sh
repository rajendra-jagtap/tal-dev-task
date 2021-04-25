#!/usr/bin/env bash

# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform


set -eou pipefail

/usr/local/bin/terraform init
/usr/local/bin/terraform apply

ansible-playbook -i lib/terraform.py app_install.yaml
