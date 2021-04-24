#!/usr/bin/env bash
cd /root/tal-dev-task/task-3
set -eou pipefail

terraform init
terraform apply

ansible-playbook -i lib/terraform.py app_install.yaml
