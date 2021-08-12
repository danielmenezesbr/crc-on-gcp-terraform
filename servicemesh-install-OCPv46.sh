set -exuo pipefail
if [ "$(whoami)" != "crcuser" ] && [ "$(whoami)" != "crcuser" ]; then
    echo "Error. Please log-in with crcuser (CRC/SNC) / root (MNC)"
    exit 1
fi
ansible-playbook servicemesh-OCPv46.yml