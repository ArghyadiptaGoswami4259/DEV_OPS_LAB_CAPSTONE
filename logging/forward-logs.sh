#!/usr/bin/env bash
set -euo pipefail

kubectl --context=taskflow-capstone \
  -n taskflow-prod logs \
  -l app=taskflow \
  --all-containers=true \
  --tail=100 |
  nc -q 1 localhost 5003
