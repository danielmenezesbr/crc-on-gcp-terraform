set -exuo pipefail
docker run -v `pwd`:/workspace -w /workspace hashicorp/terraform:0.13.6 "$@"