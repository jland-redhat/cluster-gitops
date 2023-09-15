# Developer ArgoCD

Chart used to install the "Developer Gitops" instance of ArgoCD

## ArgoRBAC

ArgoCD contains it's own RBAC system separate from the Kubernetes environment. But we can tie our Kube environment in using groups. In the `_helper-argo-rbac.tpl` file you will see the following which modifies the `rbac` section of our operator:

```yaml
{{- define "argo.rbac.policy" }}
    policy: |
      p, role:my-project-admin, projects, *, my-project, allow
      p, role:my-project-admin, repositories, *, *, allow
      p, role:my-project-admin, clusters, *, *, allow
      p, role:my-project-admin, applications, *, my-project/*, allow
      p, role:my-project-admin, applicationsets, *, my-project/*, allow
      g, system:cluster-admins, role:admin
      g, cluster-admins, role:admin
      g, argo-admins, role:admin
      g, my-project-admins, role:my-project-admin
{{- end }}
```

The lines starting with `p` are assigning a specific permission to a role and the lines starting with `g` assign a Kubernetes `Group` to that role.

So `p, role:my-project-admin, projects, *, my-project, allow` line means `role:my-project-admin` has access to create the project `my-project`:

And `g, my-project-admins, role:my-project-admin` means users that are part of the `my-project-admins` Kubernetes group will have the `role:my-project-admin` role