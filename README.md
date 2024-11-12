# DemoApp

# Google Cloud Platform environment setup and deploy modern application

The following example shows how you can set up a [Google Kubernetes Engine (GKE) cluster](https://cloud.google.com/kubernetes-engine/) and [Cloud SQL DB](https://cloud.google.com/sql) with terraform where modern aplication will be deployed and then set up an automated CI/CD pipeline using [Google Cloud Build](https://cloud.google.com/cloud-build/) for regular enhancements

## What is Google Cloud Build?

Cloud Build lets you build software quickly across all languages. Get complete control over defining custom workflows
for building, testing, and deploying across multiple environments such as VMs, serverless, Kubernetes, or Firebase.
You can find out more on the [Cloud Build](https://cloud.google.com/cloud-build/) website.

## What is Google Cloud SQL ?

Cloud SQL is a fully-managed database service that helps you set up, maintain, manage, and administer your relational databases on Google Cloud Platform. You can use Cloud SQL with MySQL, PostgreSQL, or SQL Server.You can find out more on the [Cloud SQL DB](https://cloud.google.com/sql) website.

## What is a Google Kubernetes Engine?

Google Kubernetes Engine (GKE) provides a managed environment for deploying, managing, and scaling your containerized applications using Google infrastructure. The GKE environment consists of multiple machines (specifically, Compute Engine instances) grouped together to form a cluster. You can find out more on the [Google Kubernetes Engine (GKE) cluster](https://cloud.google.com/kubernetes-engine/)

## Overview

In this guide we will walk through the steps necessary to set up a GKE cluster, cloud sql DB , deploy applications and create CI/CD pipeline using Cloud build. Here are the steps:

1. [Install the necessary tools](#installing-necessary-tools)
1. [Configure GKE cluster and deploy code](#Configure-GKE-cluster-and-deploy-code)
1. [Configure IAP and DNS ](#configure-iap-and-dns)
1. [Connect Cloud SQL DB](#connect-cloud-SQL-DB)
1. [Configure Cloud Build](#configuring-cloud-build)
1. [Trigger a build by pushing changes to GIT Repository](#triggering-a-build)
1. [View the deployment on a GKE cluster](#viewing-the-deployment)

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

QA Setup:
--------------------------------------------------------------------------------------
1. If you haven't already, clone this repo:
   - `$ git clone https://github.com/arnabgcp/BookStore.git`
1. Make sure you are in the `gke-modernize` example folder:
   - `$ cd BookStore/gke-modernize`
1. please change below default fields of variables.tf file according to your setup

   - project (should be GCP exisitng project where cluster needs to be provisioned)
   - clsname (kubernetes cluster name of your choice)
   - region (region of your choice for eg: us-central1)
   
1. Initialize terraform:
   - `$ terraform init`
1. Check the terraform plan:
   - `$ terraform plan`
1. Apply the terraform code:
   - `$ terraform apply`
   

This Terraform code will:

- create a High Available Cloud SQL Data Base in the mentioned region and imports sample data into the Bookstore DB
- Create a publicly accessible GKE cluster
- Deploy application containers on the GKE cluster (source docker images are stored on public docker hub)
- Creates an [Ingress Service](https://kubernetes.io/docs/concepts/services-networking/ingress/) for accessing the application
- show output of DB insatance which will be used in step [Connect Cloud SQL DB](#connect-cloud-SQL-DB)

At the end of `terraform apply`, we need to wait for 5-10 minutes to have a working cluster with application running on it


## Configuring Cloud Build

Your GCP project needs to be configured properly in order to use this example. This is necessary to allow Cloud Build
to access resources such as the GKE cluster.

Please refer Appendix D for more information about github repository details.

1. Please clone repository 'https://github.com/apskarthick/bookstoreonk8s.git' to your own github account and start following steps

1. If you haven't already done so, ensure the [Cloud Build API is enabled](https://console.cloud.google.com/flows/enableapi?apiid=cloudbuild.googleapis.com) in your GCP project.
   - Alternatively you may run: `gcloud services enable cloudbuild.googleapis.com --project=$PROJECT`
1. Next you will need connect git repository from cloud build

    - in [console](https://console.cloud.google.com/) please login with your credential and select required project
    - go to cloud build and select connect repository
    - select source as GitHub
    - authenticate with github credentials
    - select target repository
    - check agreement requirements and connect
       
1. Next cloud build trigger needs to be added with below terraform code.
 
1. If you haven't already, clone this repo:
   - `$ git clone https://github.com/arnabgcp/BookStore.git`
1. Make sure you are in the `gke-modernize` example folder:
   - `$ cd BookStore/cloud-build`
1. please change below default fields of variables.tf file according to your setup

   - project (should be GCP exisitng project where cluster needs to be provisioned)
   - clsname (kubernetes cluster name of your choice)
   - region (region of your choice for eg: us-central1)
   - owner (your github username)
   - branch (your github branch name)