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
[Unit]
Description=Redis container2
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker run --rm -v "/etc/ansible-provision/inadyn.conf:/etc/inadyn.conf" troglobit/inadyn:latest

[Install]
WantedBy=multi-user.target
EOL
sudo cat >crc.j2 <<EOL
[Unit]
Description=CRC
Requires=libvirtd.service
After=libvirtd.service
TimeoutSec=0
[Service]
Restart=no
ExecStart=/usr/sbin/runuser -l crcuser -c '/home/crcuser/crc/crc start'

[Install]
WantedBy=multi-user.target
EOL
sudo cat >aut.yml <<EOL
- hosts: localhost
  vars:
    password: password
    ddns_enabled: ${ddns_enabled}
  tasks:
 
    - name: setup yum-utils
      yum: name=yum-utils state=present
    - name: setup device-mapper-persistent-data
      yum: name=device-mapper-persistent-data state=present
    - name: setup lvm2
      yum: name=lvm2 state=present
    - name: Add Docker repo
      get_url:
        url: https://download.docker.com/linux/centos/docker-ce.repo
        dest: /etc/yum.repos.d/docker-ce.repo
      become: yes
    - name: setup docker-ce
      yum: name=docker-ce state=present
    - name: start docker
      service: name=docker.service enabled=yes state=started
    - name: deps
      pip: 
        name: docker-py
    - name: Log into DockerHub
      community.docker.docker_login:
        username: ${docker_login}
        password: ${docker_password}
      when: ddns_enabled
    - name: pull image troglobit/inadyn:latest
      docker_image:
        name: troglobit/inadyn:latest
      when: ddns_enabled
    - name: install myservice systemd unit file
      template: src=myservice.j2 dest=/etc/systemd/system/myservice.service
      when: ddns_enabled
    - name: start myservice
      systemd: state=started name=myservice daemon_reload=yes enabled=yes
      when: ddns_enabled
    - name: NetworkManager
      yum: name=NetworkManager state=present
    - name: Make sure we have a 'libvirt' group
      group:
        name: libvirt
        state: present
    - name: Allow 'libvirt' group to have passwordless sudo
      lineinfile:
        dest: /etc/sudoers
        state: present
        regexp: '^%libvirt'
        line: '%libvirt ALL=(ALL) NOPASSWD: ALL'
        validate: 'visudo -cf %s'
    - name: Create a login user
      user:
        name: crcuser
        password: "{{ password | password_hash('sha512') }}"
        state: present
        append: yes
        groups: libvirt
    - name: pull-secret.txt
      copy:
        dest: "/home/crcuser/pull-secret.txt"
        content: |
          ${crc_pull_secret}
    - name: Download and Extract CRC
      become_user: "crcuser"
      unarchive:
        src: https://mirror.openshift.com/pub/openshift-v4/clients/crc/1.22.0/crc-linux-amd64.tar.xz
        dest: /home/crcuser
        remote_src: yes
        group: crcuser
        owner: crcuser
        creates: /home/crcuser/crc/
    - name: Rename crc directory
      command: mv /home/crcuser/crc-linux-1.22.0-amd64/ /home/crcuser/crc/
    - name: crc consent-telemetry
      become_user: crcuser
      command: /home/crcuser/crc/crc config set consent-telemetry no
    - name: crc setup
      command: runuser -l crcuser -c '/home/crcuser/crc/crc setup'
    - name: crc config set memory
      command: runuser -l crcuser -c '/home/crcuser/crc/crc config set memory ${crc_memory}'
    - name: crc config set memory
      command: runuser -l crcuser -c '/home/crcuser/crc/crc config set enable-cluster-monitoring ${crc_monitoring_enabled}'
    - name: crc config set pull-secret-file
      command: runuser -l crcuser -c '/home/crcuser/crc/crc config set pull-secret-file /home/crcuser/pull-secret.txt'
    - name: install crc systemd unit file
      template: src=crc.j2 dest=/etc/systemd/system/crc.service
    - name: start crc
      systemd: state=started name=crc daemon_reload=yes enabled=yes
    - name: Change PATH
      shell: echo "PATH=$PATH:/home/crcuser/crc:/home/crcuser/.crc/bin/oc" > /etc/environment
      become: true

EOL
sudo ansible-playbook aut.yml #to check ansible logs: sudo journalctl -u google-startup-scripts.service -f