set -exuo pipefail
mkdir /etc/ansible-provision;
cd /etc/ansible-provision;
sudo pip3 install gdown
gdown --id 1F-2HzXPdKXnhDKkxnFLZmVyuXTRjv2EB
gdown --id 12nmicIMrZBtk7EPFl_RcIG_Votn-YUI2
tar -xf ansible29.tar.gz
sudo dnf install *.rpm -y
sudo cat >inadyn.conf <<EOL
${file_inadyn_conf}
EOL
sudo cat >myservice.j2 <<EOL
${file_myservice_j2}
EOL
sudo cat >crc.j2 <<EOL
${file_crc_j2}
EOL
sudo cat >aut.yml <<EOL
${file_aut_yml}
EOL
sudo ansible-playbook aut.yml #to check ansible logs: sudo journalctl -u google-startup-scripts.service -f