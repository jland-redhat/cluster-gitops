# Cluster Gitops

This repository is an example of how an organization could use ArgoCD/Openshift Gitops to control the infrastructure of multiple clusters from a single repository.

## Example Argo Application


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
    repoURL: 'https://github.com/jland-redhat/cluster-gitops.git'
    targetRevision: HEAD
  project: default
  syncPolicy:
    automated:
      prune: false
      selfHeal: false
```