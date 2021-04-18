###### CRC (CodeReady Containers) on GCP (Google Cloud Platform)

This repository provides an automated way to provision CRC in GCP.

Go to [Cloud Shell](https://shell.cloud.google.com/?hl=en_US&show=terminal) and run the following commands:

Create a new project:
```bash
export TF_VAR_PROJECT_ID=$(python3 -c 'import uuid; print("c" + str(uuid.uuid4().hex[:29]))')
echo "Project ID:" $TF_VAR_PROJECT_ID
gcloud projects create $TF_VAR_PROJECT_ID --name="CRConGCP" --labels=type=crc --format="json" --quiet
gcloud config set project $TF_VAR_PROJECT_ID
```

Link the new project with a billing account:

```bash
export ACCOUNT_ID=$(gcloud alpha billing accounts list --filter='open:TRUE' --format='value(ACCOUNT_ID)' --limit=1)
echo "Billing ACCOUNT ID:" $ACCOUNT_ID
gcloud alpha billing projects link $TF_VAR_PROJECT_ID --billing-account $ACCOUNT_ID
```

```bash
gcloud services enable compute.googleapis.com
```

Download and config Terraform:

```bash
wget https://releases.hashicorp.com/terraform/0.13.6/terraform_0.13.6_linux_amd64.zip
unzip terraform_0.13.6_linux_amd64.zip
export PATH=$PATH:~
git clone https://github.com/danielmenezesbr/crc-on-gcp-terraform
cd crc-on-gcp-terraform
terraform init
```

Create a [service account](https://cloud.google.com/iam/docs/service-accounts). Terraform uses the service account to provision the environment in GCP.
```bash
gcloud iam service-accounts create terraformuser
gcloud iam service-accounts keys create "terraform.key.json" --iam-account "terraformuser@$TF_VAR_PROJECT_ID.iam.gserviceaccount.com"
gcloud projects add-iam-policy-binding $TF_VAR_PROJECT_ID --member "serviceAccount:terraformuser@$TF_VAR_PROJECT_ID.iam.gserviceaccount.com" --role 'roles/owner'
```

Create pull-secret.txt. Go to [https://cloud.redhat.com/openshift/create/local](https://cloud.redhat.com/openshift/create/local]) >
`Copy pull secret` and paste below:

```
cat >pull-secret.txt <<EOL
PASTE HERE
EOL
```


Adjust the parameters in `variables.tf` if necessary.

Sensitive parameters such as passwords can be stored in the `secrets.tfvars`

```bash
cat >secrets.tfvars <<EOL
ddns_password = ""  # optional: password for freedns.afraid.org (Dynamic DNS)
docker_password = "" # optional: password for dockerhub
EOL
```

Provision the environment:
```bash
terraform apply -var-file="secrets.tfvars" -var="project_id=$TF_VAR_PROJECT_ID" -auto-approve
```

Access the instance via SSH:
```bash
gcloud compute ssh vagrant-build-1 --zone=us-central1-a --quiet
```

Wait for the message "Started the OpenShift cluster"

``` 
sudo tail -f /var/log/messages -n +1 | grep runuser
```

```
...
Apr 17 16:16:51 vagrant-build-1 runuser[51541]: Started the OpenShift cluster
Apr 17 16:16:51 vagrant-build-1 runuser[51541]: To access the cluster, first set up your environment by following the instructions returned by executing 'crc oc-env'.
Apr 17 16:16:51 vagrant-build-1 runuser[51541]: Then you can access your cluster by running 'oc login -u developer -p developer https://api.crc.testing:6443'.
Apr 17 16:16:51 vagrant-build-1 runuser[51541]: To login as a cluster admin, run 'oc login -u kubeadmin -p ABCD-EFG-hLQZX-VI9Kg https://api.crc.testing:6443'.
Apr 17 16:16:51 vagrant-build-1 runuser[51541]: You can also run 'crc console' and use the above credentials to access the OpenShift web console.
Apr 17 16:16:51 vagrant-build-1 runuser[51541]: The console will open in your default browser.
```

At this point your environment is ready.

The `crcuser` operating system user runs CRC.
The password for `crcuser` is `password`.

If you want to use [`oc`](https://docs.openshift.com/container-platform/4.6/cli_reference/openshift_cli/getting-started-cli.html) 
after enter into via SSH 
use the user crcuser. For example:

After accessing the instance via SSH, 
change to the `crcuser` user if you 
want to run `crc` or  [`oc`](https://docs.openshift.com/container-platform/4.6/cli_reference/openshift_cli/getting-started-cli.html). 
For example:

```
su - crcuser
```

```
crc status
```

```
CRC VM:          Running
OpenShift:       Starting (v4.6.15)
Disk Usage:      13.16GB of 32.72GB (Inside the CRC VM)
Cache Usage:     14.31GB
Cache Directory: /home/crcuser/.crc/cache
```

```
oc login -u kubeadmin -p $(crc console --credentials | awk -F "kubeadmin" '{print $2}' | cut -c 5- | rev | cut -c31- | rev) https://api.crc.testing:6443
```

```
Login successful.

You have access to 58 projects, the list has been suppressed. You can list all projects with ' projects'

Using project "default".
```

```
oc get nodes
```

```
NAME                 STATUS   ROLES           AGE   VERSION
crc-ctj2r-master-0   Ready    master,worker   74d   v1.19.0+1833054
```