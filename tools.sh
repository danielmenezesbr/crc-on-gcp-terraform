# This follows https://blog.openshift.com/enabling-openshift-4-clusters-to-stop-and-resume-cluster-vms/
# in order to trigger regeneration of the initial 24h certs the installer created on the cluster
function renew_certificates() {
    shutdown_vms

    # Enable the network time sync and set the clock back to present on host
    sudo date -s '1 day'
    sudo timedatectl set-ntp on

    start_vms

    # After cluster starts kube-apiserver-client-kubelet signer need to be approved
    timeout 300 bash -c -- "until oc get csr | grep Pending; do echo 'Waiting for first CSR request.'; sleep 2; done"
    oc get csr -ojsonpath='{.items[*].metadata.name}' | xargs oc adm certificate approve

    # Retry 5 times to make sure kubelet certs are rotated correctly.
    i=0
    while [ $i -lt 5 ]; do
        if ! ${SSH} core@api.${CLUSTER_NAME}.${BASE_DOMAIN} -- sudo openssl x509 -checkend 2160000 -noout -in /var/lib/kubelet/pki/kubelet-client-current.pem; then
	          # Wait until bootstrap csr request is generated with 5 min timeout
	          echo "Retry loop $i, wait for 60sec before starting next loop"
            sleep 60
	      else
            break
        fi
	      i=$[$i+1]
    done

    if ! ${SSH} core@api.${CLUSTER_NAME}.${BASE_DOMAIN} -- sudo openssl x509 -checkend 2160000 -noout -in /var/lib/kubelet/pki/kubelet-client-current.pem; then
        echo "Certs are not yet rotated to have 30 days validity"
	      exit 1
    fi
}

function shutdown_vms {
    for i in $(sudo virsh list --name --autostart);
    do
      retry sudo virsh shutdown $i;
      until sudo virsh domstate $i | grep shut; do
        echo " $i still running"
        sleep 3
      done
    done

    #local vm_prefix=$1
    #retry sudo virsh shutdown ${vm_prefix}-master-0
    ## Wait till instance started successfully
    #until sudo virsh domstate ${vm_prefix}-master-0 | grep shut; do
    #    echo " ${vm_prefix}-master-0 still running"
    #    sleep 3
    #done
}

function start_vms {
  for i in $(sudo virsh list --all --name);
  do
    retry sudo virsh start $i
  done

  # Wait till ssh connection available
  until ${SSH} core@api.${CLUSTER_NAME}.${BASE_DOMAIN} -- "exit 0" >/dev/null 2>&1; do
      echo " $i still booting"
      sleep 2
  done
    #local vm_prefix=$1
    #retry sudo virsh start ${vm_prefix}-master-0
    ## Wait till ssh connection available
    #until ${SSH} core@api.${CRC_VM_NAME}.${BASE_DOMAIN} -- "exit 0" >/dev/null 2>&1; do
    #    echo " ${vm_prefix}-master-0 still booting"
    #    sleep 2
    #done
}

function retry {
    local retries=10
    local count=0
    until "$@"; do
        exit=$?
        wait=$((2 ** $count))
        count=$(($count + 1))
        if [ $count -lt $retries ]; then
            echo "Retry $count/$retries exited $exit, retrying in $wait seconds..."
            sleep $wait
        else
            echo "Retry $count/$retries exited $exit, no more retries left."
            return $exit
        fi
    done
    return 0
}