set -exuo pipefail
cat >/etc/login.warn <<EOL
${file_banner}
EOL
cat >/etc/motd <<EOL
${file_banner}
EOL
#while $(sleep 10); do
#  echo "waiting for systemd to finish booting..."
#  if systemctl is-system-running | grep -qE "running|degraded"; then
#    break
#  fi
#done
#echo "systemd finished booting..."
echo "setting metadata_timer_sync=0" >> /etc/dnf/dnf.conf
systemctl stop dnf-makecache.timer
systemctl disable dnf-makecache.timer
yum module enable -y container-tools:rhel8
yum module install -y container-tools:rhel8
mkdir /etc/ansible-provision;
cd /etc/ansible-provision;
pip3 install gdown
gdown --id 1F-2HzXPdKXnhDKkxnFLZmVyuXTRjv2EB
gdown --id 12nmicIMrZBtk7EPFl_RcIG_Votn-YUI2
tar -xf ansible29.tar.gz
dnf install *.rpm -y
cat >/tmp/inadyn.conf <<EOL
${file_inadyn_conf}
EOL
cat >/tmp/myservice.j2 <<EOL
${file_myservice_j2}
EOL
cat >/tmp/crc.j2 <<EOL
${file_crc_j2}
EOL
echo "${file_aut_yml}"
echo "${file_aut_yml}" | base64 -d > /tmp/aut.yml
cp -a /tmp/inadyn.conf .
cp -a /tmp/myservice.j2 .
cp -a /tmp/crc.j2 .
cp -a /tmp/aut.yml .
ansible-playbook aut.yml
#to check ansible logs:
#sudo journalctl -u google-startup-scripts.service -f