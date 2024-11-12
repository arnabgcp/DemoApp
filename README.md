# DemoApp

# Google Cloud Platform environment setup and deploy modern application

The following example shows how you can set up a multi cluster [Google Kubernetes Engine (GKE) cluster](https://cloud.google.com/kubernetes-engine/) integrated with vault with terraform where modern aplication will be deployed and then set up an automated CI/CD pipeline using [Google Cloud Build](https://cloud.google.com/cloud-build/) and ArgoCD ( GitOps ) for regular enhancements

## What is Google Cloud Build?

Cloud Build lets you build software quickly across all languages. Get complete control over defining custom workflows
for building, testing, and deploying across multiple environments such as VMs, serverless, Kubernetes, or Firebase.
You can find out more on the [Cloud Build](https://cloud.google.com/cloud-build/) website.


## What is a Google Kubernetes Engine?

Google Kubernetes Engine (GKE) provides a managed environment for deploying, managing, and scaling your containerized applications using Google infrastructure. The GKE environment consists of multiple machines (specifically, Compute Engine instances) grouped together to form a cluster. You can find out more on the [Google Kubernetes Engine (GKE) cluster](https://cloud.google.com/kubernetes-engine/)

## Overview

In this guide we will walk through the steps necessary to set up a GKE cluster, cloud sql DB , deploy applications and create CI/CD pipeline using Cloud build. Here are the steps:

1. [Install the necessary tools](#installing-necessary-tools)
1. [Configure GKE cluster and deploy code](#Configure-GKE-cluster-and-deploy-code)
1. [Configure Cloud Build](#configuring-cloud-build)
1. [Configuring ArgoCD](#Configuring-ArgoCD)
1. [Configuring the private GKE clusters](#Configuring-the-private-GKE-clusters)
1. [Vault integration with the private GKE clusters](#Vault-integration-with-the-private-GKE-clusters)   

## Installing necessary tools

In addition to `terraform`, this guide relies on the `gcloud` and `kubectl` tools to view build information and manage
the GKE cluster. This means that your system needs to be configured to be able to find `terraform`, `gcloud`, `kubectl`
client utilities on the system `PATH`. Here are the installation guides for each tool:

1. [`gcloud`](https://cloud.google.com/sdk/gcloud/)
1. [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
1. [`terraform`](https://learn.hashicorp.com/terraform/getting-started/install.html)

Make sure the binaries are discoverable in your `PATH` variable. See [this Stack Overflow
post](https://stackoverflow.com/questions/14637979/how-to-permanently-set-path-on-linux-unix) for instructions on
setting up your `PATH` on Unix, and [this
post](https://stackoverflow.com/questions/1618280/where-can-i-set-path-to-make-exe-on-windows) for instructions on
Windows.

## Configure GKE cluster and deploy code

Now that we have installed necessary tools, we are ready to deploy all of the example resources in QA environment and PROD environment and also set up the Cloud
Build triggers!

--------------------------------------------------------------------------------------
1. If you haven't already, clone this repo:
   - `$ git clone https://github.com/arnabgcp/DemoApp.git`
1. Make sure you are in the `IAC` folder:
   - `$ cd DemoApp/IAC`
1. please change below default fields of main.tf file according to your setup

   - project (should be GCP exisitng project where cluster needs to be provisioned)
   - region_pri ( 1st cluster member subnet)
   - region_sec ( 2nd cluster member subnet)
1. Below details needs to be added module wise according to preference      
   - loc ( zone of the primary and secondary region for both modules)
   - name ( name of your choise )
   - nodecount ( node needed for the application )
   - master_ipvr ( add this for the private gke )
   - shell ( needed to add from where you want to connect to the private gke )
   
1. Initialize terraform:
   - `$ terraform init`
1. Check the terraform plan:
   - `$ terraform plan`
1. Apply the terraform code:
   - `$ terraform apply`
   

This Terraform code will:

- create a network with subnets with given details
- Adds NAT into those subnets
- Create two GKE clusters for High availability

`terraform apply` can take upto 15-20 minutes ( please watch for quota issues )


## Configuring Cloud Build

Your GCP project needs to be configured properly in order to use this example. This is necessary to allow Cloud Build
to access resources such as the GKE cluster.


1. Please clone repository 'https://github.com/arnabgcp/DemoApp.git' to your own github account and start following steps

1. If you haven't already done so, ensure the [Cloud Build API is enabled](https://console.cloud.google.com/flows/enableapi?apiid=cloudbuild.googleapis.com) in your GCP project.
   - Alternatively you may run: `gcloud services enable cloudbuild.googleapis.com --project=$PROJECT`
1. Next you will need connect git repository from cloud build

    - in [console](https://console.cloud.google.com/) please login with your credential and select required project
    - go to cloud build and select connect repository
    - select source as GitHub
    - authenticate with github credentials
    - select target repository
    - check agreement requirements and connect
    - Add new trigger
    - Provide name
    - Trigger should be pushed to a branch and provide `https://github.com/arnabgcp/BookStore.git` as source
    - in the inclusion section add apps/** ( it will make sure any app change will only trigger the build )
    - build file is in git repo

## Configuring ArgoCD

1. Connect to first member gke cluster and run below commands to install argocd components

    - kubectl create namespace argocd
    - kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

2. Install argocd cli to work with the deployment
   
    - curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    - sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    - rm argocd-linux-amd64
  
3. Addition of the second member ( Please add NAT ips in the master authorized hosts before this step since we have private GKE cluster )

   - argocd login <ARGOCD_SERVER>
   - kubectl config get-contexts
   - argocd cluster <2nd member cluster>
   - kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/applicationset/v0.3.0/manifests/install.yaml ( This is for ArgoCD multi cluster deployment )
  

## Configuring the private GKE clusters

We need to run below steps in both GKE clusters so that they can fetch secrets from vault

   - helm repo add external-secrets https://charts.external-secrets.io 
   - helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace
   - gcloud container fleet ingress update --config-membership=projects/$PROJECT/locations/$ZONE/memberships/$FIRST_MEMEBR_CLUSTER ( We need to enable MCI and MCS for HA )
   - kubectl apply -f appliation.yaml ( We should be under directory DemoApp, this should create deployment files, secrets, service accounts ,multi cluster services, multi cluster ingress )

Once done our deployment files are ready but waiting for vault integration


## Vault integration with the private GKE clusters

We are assuming vault is already hosted in a VM. Below are the steps to install vault command line

   - sudo apt update && sudo apt install gpg wget
   - wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
   - gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
   - echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
   - sudo apt update && sudo apt install vault
   - export VAULT_ADDR=http://vault-host:8200
   - vault auth enable -path=cluster-1 kubernetes
   - vault auth enable -path=cluster-2 kubernetes
   - vault write auth/cluster-1/role/demo \
       bound_service_account_names=* \
       bound_service_account_namespaces=* \
       policies=default \
       ttl=1h
   - vault write auth/cluster-2/role/demo \
       bound_service_account_names=* \
       bound_service_account_namespaces=* \
       policies=default \
       ttl=1h
     
We need execute below commands for both the clusters 

   - sudo apt update && sudo apt install gpg wget
   - export SA_SECRET_NAME=$(kubectl get secrets --output=json | jq -r '.items[].metadata | select(.name|startswith("vault-auth-")).name')
   - export SA_JWT_TOKEN=$(kubectl get secret $SA_SECRET_NAME --output 'go-template={{ .data.token }}' | base64 --decode)
   - export K8S_HOST=$(kubectl config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.server}')
   - export SA_CA_CRT=$(kubectl -n default get secret $SA_SECRET_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)
   - vault write auth/cluster-1/config \
     token_reviewer_jwt="$SA_JWT_TOKEN" \
     kubernetes_host="$K8S_HOST" \
     kubernetes_ca_cert="$SA_CA_CRT" \
     issuer="https://kubernetes.default.svc.cluster.local"
   - vault write auth/cluster-2/config \
     token_reviewer_jwt="$SA_JWT_TOKEN" \
     kubernetes_host="$K8S_HOST" \
     kubernetes_ca_cert="$SA_CA_CRT" \
     issuer="https://kubernetes.default.svc.cluster.local"

Please add below policy under default in vault

   - path "secret/*" {
          capabilities = [ "read", "list" ]
         }
     
Now our deployment should be ready and below is the application architecture






   
   
   
