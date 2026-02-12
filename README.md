# My Personal Website Portfolio - K8s Configuration

This repository contains the Kubernetes configuration files for my personal portfolio website, managed through Helm charts and deployed via an ArgoCD app-of-apps pattern.

This repository is part of a 3-repository stack for my website application. I have "helmed" my Kubernetes files for a templated and more manageable approach. I added some instructions in the `NOTES.txt` file regarding the ArgoCD view.

## 🏛️ Project Architecture

This website is part of a larger cloud-native project, deployed on AWS EKS. The entire infrastructure and deployment pipeline are managed across three dedicated repositories:

* **🌐 [mywebsite-app](https://github.com/liormilliger/mywebsite-app.git):** Contains the Python/Flask application code, HTML/CSS for the frontend, and Docker configuration for containerization.

* **🔧 [mywebsite-k8s](https://github.com/liormilliger/mywebsite-k8s.git) (This Repo):** Holds the Kubernetes deployment files and ArgoCD App-of-Apps manifests for GitOps-based deployment.

* **🏗️ [mywebsite-iac](https://github.com/liormilliger/mywebsite-iac.git):** Includes the Terraform Infrastructure as Code (IaC) to provision the AWS VPC, EKS cluster, and deploy ArgoCD via its Helm chart.

## 🚀 ArgoCD App-of-Apps

The `argocd-apps` folder contains the application definition files for the supporting apps I am managing with ArgoCD. This 'app-of-apps' pattern automatically deploys and manages all the essential services for my cluster and my personal projects.

The stack is deployed in waves to manage dependencies and includes:

* **Prometheus Stack (Monitoring):**
    * `prometheus-stack-crds`: This application is deployed in the first sync wave (`-1`) and installs *only* the Custom Resource Definitions (CRDs) for the `kube-prometheus-stack`. This ensures the Kubernetes API recognizes resources like `ServiceMonitor` and `PodMonitor` before any other components are deployed.
    * `prometheus-stack`: This deploys the full monitoring stack, including **Prometheus** for metrics collection and **Grafana** for visualization. It's configured to skip the CRDs since they are managed separately.

* **Elastic Stack (Logging):**
    * `eck-operator`: Deployed in sync wave `0`, this installs the **Elastic Cloud on Kubernetes (ECK) Operator**. This operator is responsible for managing the lifecycle of all Elastic components (Elasticsearch, Kibana, Filebeat) as native Kubernetes resources.
    * `eck-stack`: This application deploys the actual logging cluster (likely **Elasticsearch** for storage/search and **Kibana** for visualization) using the `eck-stack` Helm chart. It runs in sync wave `1`, ensuring the operator is ready first.
    * `filebeat-eck`: Deployed as a DaemonSet in wave `2`, **Filebeat** runs on every node to collect container logs. It's configured to send these logs directly to the Elasticsearch cluster managed by ECK.

* **Ingress & Networking:**
    * `aws-load-balancer-controller`: This deploys the **AWS Load Balancer Controller**, which is essential for running on EKS. It automatically provisions and manages AWS Application Load Balancers (ALBs) whenever a Kubernetes `Ingress` resource is created.

* **My Application:**
    * `my-website`: This is the primary application, my personal portfolio website. It's deployed from the `liormilliger/mywebsite-k8s` Git repository and runs in the final sync wave (`3`), ensuring all cluster services (monitoring, logging, ingress) are fully operational first.

## ⚙️ Helm Charts

The Kubernetes manifests for the main website application are packaged as a Helm chart to allow for templated, configurable, and repeatable deployments. This approach simplifies the management of different environments and configurations.