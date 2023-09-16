#!/usr/bin/env bash

# Used for terragrunt modules.
HTTP_PROXY=http://10.79.90.46:443
export HTTP_PROXY

# Used for cloning our custom modules.
HTTPS_PROXY=http://10.79.90.46:443
export HTTPS_PROXY

echo "Remember to unset HTTP_PROXY and HTTPS_PROXY before running 'terragrunt apply'."
