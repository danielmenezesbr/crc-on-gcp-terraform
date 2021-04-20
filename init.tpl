sudo dnf makecache;
sudo dnf install epel-release -y;
sudo dnf makecache;
sudo dnf install ansible -y;
ansible-galaxy collection install community.docker;
mkdir /etc/ansible-provision;
cd /etc/ansible-provision;
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