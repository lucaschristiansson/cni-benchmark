#!/usr/bin/env bash
set -euo pipefail

multipass delete --purge cp w1 w2 || true
rm -f ~/.kube/config
