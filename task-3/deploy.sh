#!/usr/bin/env bash
cd task-3
set -eou pipefail

terraform init
terraform apply

ansible-playbook -i lib/terraform.py app_install.yaml
