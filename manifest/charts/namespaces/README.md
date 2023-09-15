# Namespace App of Apps

A helm chart that can take in a list of `namespaces` and deploy them using the `namespace-base` chart.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| clusterName | Name of the folder inside of `/cluster`. Used to retrieve value files | `"example-cluster-2"` |  |
| namespaces | List of namespaces to deploy | `["example-namespace-1", "example-namespace2']` |  |
| targetRevision | Branch/Tag of this repository that should be used for the deployment | `"HEAD"` |  |

> **Important:** This chart assumes that `/cluster/<CLUSTER_NAME>/namespaces` contains a `<NAMESPACE_NAME>.yaml` file for every namespace passed in. This is what will be used during the actual deployment.
