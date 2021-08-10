set -exuo pipefail
mkdir /etc/ansible-provision;

cat >/etc/profile.d/env.sh <<'EOL'
export strategy=${strategy}
alias 0='cat /etc/login.warn'
alias 1='sudo journalctl -u google-startup-scripts.service -f'
case $strategy in
        crc)
                alias 2='sudo tail -f /var/log/messages -n +1 | grep runuser'
                ;;
        snc)
                alias 2='sudo tail -f /home/crcuser/snc/install.out'
                ;;
        mnc)
                alias 2='sudo tail -f /home/crcuser/clusters/mycluster/install.out'
                ;;
        *)
                alias 2='echo please review /etc/profile.d/env.sh'
                ;;
esac
alias 3='su - crcuser'
EOL

function fail {
  echo $1 >&2
  exit 1
}

function retry {
  local n=1
  local max=5
  local delay=15
  while true; do
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        echo "Command failed. Attempt $n/$max:"
        sleep $delay;
      else
        fail "The command has failed after $n attempts."
      fi
    }
  done
}
cat >/etc/login.warn <<EOL
${file_banner}
EOL
cat >/etc/motd <<EOL
${file_banner}
EOL
###TEMP
pip3 install --upgrade pip
pip3 install ipaddr
pip3 install netaddr
pip3 install 'ansible==2.9.24'
exit 0
echo "setting metadata_timer_sync=0" >> /etc/dnf/dnf.conf
systemctl stop dnf-makecache.timer
systemctl disable dnf-makecache.timer
systemctl stop dnf-automatic.timer
systemctl disable dnf-automatic.timer
cd /etc/ansible-provision;
pip3 install gdown
gdown --id 1F-2HzXPdKXnhDKkxnFLZmVyuXTRjv2EB
gdown --id 12nmicIMrZBtk7EPFl_RcIG_Votn-YUI2
tar -xf ansible29.tar.gz
ps aux | grep "automatic.conf --timer"
kill $(ps aux | grep 'automatic.conf --timer' | awk '{print $2}') || true
retry dnf install *.rpm -y
cat >/tmp/inadyn.conf <<'EOL'
${file_inadyn_conf}
EOL
cat >/tmp/ddns.j2 <<'EOL'
${file_ddns_j2}
EOL
cat >/tmp/crc.j2 <<'EOL'
${file_crc_j2}
EOL
cat >/tmp/tools.sh <<'EOL'
${file_tools_sh}
EOL
echo "${file_provision_yml}"
echo "${file_provision_yml}" | base64 -d > /tmp/provision.yml
cp -a /tmp/inadyn.conf .
cp -a /tmp/ddns.j2 .
cp -a /tmp/crc.j2 .
cp -a /tmp/provision.yml .
ansible-playbook provision.yml
#to check ansible logs:
#sudo journalctl -u google-startup-scripts.service -f
