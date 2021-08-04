set -exuo pipefail
if [ "$(whoami)" != "crcuser" ] ; then
    echo "Error. Please log-in with crcuser."
    exit 1
fi
ansible-playbook servicemesh-OCPv46.yml