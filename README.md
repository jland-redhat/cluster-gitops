# Cluster Gitops

This repository is an example of how an organization could use ArgoCD/Openshift Gitops to control the infrastructure of multiple clusters from a single repository. All new clusters created should used this repository to install internal infrastructure.

## Technologies

This repo makes use of the following:
- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/)/[Openshift Gitops](https://docs.openshift.com/container-platform/latest/cicd/gitops/understanding-openshift-gitops.html) - Cluster level service used to deploy the application
- [Kustomize](https://kustomize.io/) - Kubernetes native configuration management
- [Helm](https://helm.sh/) - Kubernetes package manager used for tempesting

## Folder Breakdown

``` sh
  cluster (1)
  ├── example-cluster-1
  │   ├── kustomization.yml
  env
  ├── dev (2)
  │   ├── kustomization.yml
  ├── nonprod
  │   ├── kustomization.yml
  ├── prod
  │   ├── kustomization.yml
  manifest (3)
  ├── argo (3a)
  └── charts (3b)
```

  1. Within each `cluster` folder, you'll find a Kustomize Template that represents a distinct cluster. These templates inherit from an `env` template.
  2. Inside every `env` folder, you'll discover a Kustomize Template designed for shared resources within the environment.
  3. The Manifest folder contains templates for deploying various architectural features.
       - Contains a set of Kustomize Templates for deploying the Argo `Application` pointing to the appropriate Helm chart
       - Contains a set of Helm Charts that represent the different components installed onto the cluster

## Cluster Management

This section will talk about managing specific clusters using this repository.

### Adding a New Cluster

Once the inital install of the cluster has been completed use the following instructions for installation of the inital infrastructure

#### Create Cluster Folder

Create a new folder under the `/cluster` folder with an appropriately descriptive name. And a `kustomization.yml` file with the following content

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../env/<ENVIRONMENT>

```

Any cluster specific customizations can be put under the `patches` section. For more information about using [Kustomize](https://kustomize.io/) refer to the official documentation.

#### Install `Openshift-Gitops` Operator

To install the `Openshift-Gitops` operator, please perform a manual installation for the time being. This installation process will create the `openshift-gitops` namespace. Within this namespace, you'll find the ArgoCD instance. You can access this instance via the URL located in the `Network -> Routes` section or through the square menu at the top of the `Openshift UI`.

#### Add our `App of Apps`

This repository leverages the [App of Apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/) approach for bootstrapping our cluster. This means that we only need to create our initial Argo Application, and it will automatically generate all the other required applications for us.

To achieve this, please create the following Application within the `openshift-gitops` namespace:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-config
spec:
  destination:
    namespace: openshift-gitops
    server: 'https://kubernetes.default.svc'
  source:
    path: cluster/example-cluster-1
    repoURL: 'https://github.com/jland-redhat/cluster-gitops.git' #Replace this with your forked cluster
    targetRevision: HEAD
  project: default
  syncPolicy:
    automated:
      prune: false
      selfHeal: false
```

### Adding a Namespace to a Cluster

Namespaces creation/deletion can be managed through this repository using ArgoCD. To add a new namespace do the following:

1. If this is the first namespace update the `kustomization.yml` file to include the following context

  ```yaml
  patchesStrategicMerge:
    - patch-namespace-list.yaml
  ```

2. Create/Update `patch-namespace-list.yaml` with new namespace. Content should look like the following:

  ```yaml
  apiVersion: argoproj.io/v1alpha1
  kind: Application
  metadata:
    name: namespaces-app
  spec:
    source:
      helm:
        values: |
            clusterName: example-cluster-2
            namespaces:
              - <NAMESPACE_NAME>
  ```

3. Create a file inside of `namespaces/<NAMESPACE-NAME>.yaml` with the following content:

  ```yaml
  name: example-namespace-1
  owner: group-a
  # Future required values for namespace creation...
  ```

### Developer Argo Instance

The `manifest/charts/developer-argo` Helm chart deploys a different instance of `ArgoCD` within the `developer-gitops` namespace. This approach allows developers to leverage ArgoCD for their deployments while minimizing potential risks by not requiring access to the centralized ArgoCD instance.

An essential integration note: The `ServiceAccount` employed by the `developer-gitops` Argo instance does not inherently possess access to all namespaces. However, if the namespace was deployed using the `namespace-base` chart, it should include the `RoleBinding` named `dev-argo-admin`. This role binding grants the `developer-gitops-argocd-application-controller` ServiceAccount admin-level access to that specific namespace.

### Adding a new Component

This repository can be expanded to contain any and all infrastructure pieces of an enterprises cluster. Any new components can be added with the following:

1. Create a [helm chart](https://helm.sh/docs/topics/charts/) that contains all the required Kubernetes objects under `manifest/charts`
   1. Here is an [Intro to Helm](https://appdev.consulting.redhat.com/tracks/devtools/helm-intro.html) for anyone new to creating charts
2. Create a Kustomize template inside `/manifest/argo` containing a single [ArgoCD Application](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#applications) pointing to the previously created `helm chart`
   1. Use other `Argo Applications` inside of that folder as examples
3. Add new component to the environment's base by updating the `kustomization.yaml` inside of `/env/<ENVIRONMENT_NAME>`
4. Apply any necessary `Kustomize patches` to either the environment or cluster level as required.

