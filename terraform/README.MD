## Introduction

This directory contains the [Terraform](https://www.terraform.io/) files to spin up a simple IOMETE environment in Azure.
It creates:

* A resource group, named after `environment_name` (`iomete-sample` by default).
* An AKS cluster, with one autoscaling node pool of `Standard_D4s_v3` nodes (1 to 6 nodes).
* An Azure Database for PostgreSQL Flexible Server for IOMETE's metadata, plus the `iomete_user` login IOMETE connects as.
* [Apache Ozone](https://ozone.apache.org/) in namespace `infra`, as the S3-compatible object storage, with the `lakehouse` bucket.
* IOMETE (chart `iomete-data-plane-enterprise`) and the IOMETE monitoring chart in namespace `iomete-system`.

This setup is for testing. Ozone runs as a single datanode with one copy of each object and without
authentication, and PostgreSQL is reachable from the internet. See [Apache Ozone deployment](https://iomete.com/resources/deployment/ozone-deployment)
for what a production object store needs.

## Environment setup

### Required tools

To run this on your local machine, you will need the following CLI tools installed:
* [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
* [azure cli](https://learn.microsoft.com/en-us/cli/azure/?view=azure-cli-latest)
* [terraform cli](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) 1.6 or later

For those running on macOS, using [homebrew](https://brew.sh/) you can run below commands to install:
```shell
brew update && brew upgrade
brew install kubernetes-cli
brew install hashicorp/tap/terraform
brew install azure-cli
```

Log in to Azure. Terraform uses this login:
```shell
az login
```

### Settings

Copy the example settings file and fill it in:
```shell
cp terraform.tfvars.example terraform.tfvars
```

* `azure_subscription_id`: your [Azure subscription id](https://learn.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id)
* `azure_region`: the Azure region to create everything in, for example `germanywestcentral`
* `iomete_admin_email`: the email of the IOMETE console admin user

The file also lists the optional settings, such as the chart versions and the PostgreSQL size.
`terraform.tfvars` is git-ignored.

### Terraform state (optional)

By default Terraform keeps its state in a local `terraform.tfstate` file. To store it in Azure instead,
create a storage account and container:
```shell
# assumes the Azure resource group `terraform-state-rg` exists
az storage account create \
    --name <unique-storage-account-name> \
    --resource-group terraform-state-rg \
    --location germanywestcentral \
    --sku Standard_LRS \
    --kind StorageV2 \
    --allow-blob-public-access false

az storage container create \
    --name tfstate \
    --account-name <unique-storage-account-name>
```

Then add an empty backend block to the `terraform` block in [providers.tf](providers.tf):
```hcl
backend "azurerm" {}
```

and pass its settings to `terraform init`:
```shell
terraform init \
    -backend-config="resource_group_name=terraform-state-rg" \
    -backend-config="storage_account_name=<unique-storage-account-name>" \
    -backend-config="container_name=tfstate" \
    -backend-config="key=iomete/kubernetes.tfstate"
```

## Creating a new IOMETE environment

### Installing IOMETE

Initialize Terraform:
```shell
terraform init -upgrade
```

Look at what Terraform plans to create:
```shell
terraform plan
```

When the plan looks right, apply it:
```shell
terraform apply
```

The first apply takes about 20 to 30 minutes. Most of it is the AKS cluster, the PostgreSQL server and
the IOMETE Helm release.

### Testing IOMETE

Point `kubectl` at the new cluster:
```shell
az aks get-credentials --resource-group iomete-sample --name iomete-sample-aks-cluster
```

This Terraform doesn't add a DNS entry or an ingress, since that depends on each company's setup.
For testing, use port-forwarding:
```shell
kubectl port-forward service/iom-gateway -n iomete-system 12345:80
```

Then open http://localhost:12345 and log in as `admin` with the temporary password, which you change on first login:
```shell
terraform output -raw iomete_console_admin_password
```

All other sensitive outputs are in [outputs.tf](outputs.tf).

To check the object storage, list the lakehouse bucket from inside the cluster:
```shell
kubectl run s3-check -n infra --rm -it --restart=Never \
  --image=public.ecr.aws/aws-cli/aws-cli:2.37.6 \
  --env=AWS_ACCESS_KEY_ID=iomete \
  --env=AWS_SECRET_ACCESS_KEY="$(terraform output -raw ozone_s3_secret_key)" \
  --env=AWS_REGION=us-east-1 \
  -- --endpoint-url http://ozone-s3g-rest.infra.svc.cluster.local:9878 s3 ls s3://lakehouse --recursive
```

To open Ozone's web UI, Recon, which shows the cluster health, datanodes and a browser for the buckets:
```shell
kubectl port-forward service/ozone-recon -n infra 9888:9888
```
Then open http://localhost:9888. Recon refreshes from Ozone every few minutes, so new data can take a while to appear.
Set `ozone_recon_enabled = false` to leave it out.

### Tearing down the environment

To remove the entire installation, you can run:

```shell
terraform destroy
```

This deletes every disk, so all lakehouse data in Ozone is lost. In case of issues or Terraform not
being able to correctly spin down the environment, you can always remove the entire resource group from Azure.
