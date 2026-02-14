# node-js-sample-k8s

This repository serves as the **GitOps Control Plane** for the Node.js application ecosystem. It manages the desired state of the Kubernetes cluster, including Helm charts, monitoring configurations, and automated deployment logic.

## Project Ecosystem

This project is the central hub of a **3-repository GitOps architecture**:

1.  **[Application Repo (sample-nodejs-app)](https://github.com/liormilliger/sample-nodejs-app.git)**: Source code and CI pipeline that updates this repo's image tags.
2.  **GitOps Repo (This one)**: Declarative manifests, Helm charts, and ArgoCD "App of Apps" logic.
3.  **[Infrastructure Repo (terraform-iac)](https://github.com/liormilliger/terraform-iac.git)**: Terraform code for EKS, VPC, and AWS resource provisioning.

### System Architecture
![System Architecture](./system-architecture.png)

---

## Deployment Workflow (ArgoCD)

This repository implements the **App of Apps pattern**, allowing a single "root" application to manage all other components.

### 1. Multi-Stage Synchronization
* **Sync Waves**: Resources are ordered using `argocd.argoproj.io/sync-wave`.
* **CRD Management**: Prometheus Custom Resource Definitions (CRDs) are deployed first (Wave -1) to ensure the cluster can process `ServiceMonitor` and `Prometheus` objects.
* **Application Layer**: The Node.js application is deployed in a later wave to ensure monitoring infrastructure is ready.

### 2. Automated Image Updates
* **GitOps Bridge**: When the CI pipeline in the Application repo completes, it performs a "write-back" to this repository.
* **Tag Modification**: The `image.tag` in `my-app-chart/values.yaml` is updated automatically via `sed`.
* **Self-Healing**: ArgoCD detects the Git diff and synchronizes the cluster to match the new versioned tag.

---

## Monitoring & Dashboard-as-Code

We treat observability as part of our infrastructure code.

* **Service Discovery**: A `ServiceMonitor` resource is used to allow the Prometheus Operator to dynamically discover and scrape the Node.js metrics endpoint.
* **Automated Dashboards**: Grafana dashboards are stored as JSON files in the `./dashboards/` directory.
* **ConfigMap Injection**: We use Helm's `.Files.Get` functionality to inject JSON into Kubernetes ConfigMaps.
* **Sidecar Import**: A sidecar container in the Grafana pod watches for the `grafana_dashboard: "1"` label and automatically imports the dashboards into the UI.

---

## Repository Structure
* **`/my-app-chart`**: The primary Helm chart for the Node.js application.
* **`/my-app-chart/dashboards`**: JSON definitions for Grafana performance views.
* **`/argocd-apps`**: ArgoCD `Application` files that define the "App of Apps" structure.

