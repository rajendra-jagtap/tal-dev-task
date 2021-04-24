#!/usr/bin/env bash
set -eou pipefail

/usr/local/bin/terraform init
/usr/local/bin/terraform apply

ansible-playbook -i lib/terraform.py app_install.yaml
