# Namespace Base

Chart used for deploying a specific namespace

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| name | Namespace Name | `"example"` |  |

## Expanding

Currently this chart deploys the namespace, a `RoleBinding` used by our dev argo to access the namespace, and a genaric `RBAC` that grants `Group` "admin-group" admin priviliages.

> Note: it does not create the admin group