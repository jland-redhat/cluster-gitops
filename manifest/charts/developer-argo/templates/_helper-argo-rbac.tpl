{{- define "argo.rbac.policy" }}
    policy: |
      p, role:my-project-admin, projects, *, my-project
      p, role:my-project-admin, applications, *, my-project/*, allow
      p, role:my-project-admin, applicationsets, *, my-project/*, allow
      g, system:cluster-admins, role:admin
      g, cluster-admins, role:admin
      g, argo-admins, role:admin
      g, my-project-admins, role:my-project-admin
{{- end }}