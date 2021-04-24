#!/usr/bin/env bash
set -eou pipefail

terraform init
terraform apply

ansible-playbook -i lib/terraform.py app_install.yaml
