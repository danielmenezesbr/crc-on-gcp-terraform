set -exuo pipefail
if [ "$(whoami)" != "crcuser" ] && [ "$strategy" != "mnc" ]; then
    echo "Error. Please log-in with crcuser."
    exit 1
elif [ "$(whoami)" != "root" ] && [ "$strategy" == "mnc" ]; then
    echo "Error. Please log-in with root."
    exit 1
fi
ansible-playbook servicemesh-OCPv46.yml