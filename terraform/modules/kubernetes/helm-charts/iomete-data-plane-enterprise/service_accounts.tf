resource "kubernetes_service_account" "lakehouse_service_account" {
  depends_on = [helm_release.iomete_crds]
  metadata {
    name = "lakehouse-service-account"
    namespace = var.namespace
    annotations = {}
  }

  image_pull_secret {
  }
}


resource "kubernetes_role" "iomete_lakehouse_role" {
  metadata {
    name = "iomete-lakehouse-role"
    namespace = var.namespace
  }

  rule {
    verbs = ["*"]
    api_groups = [""]
    resources = [
      "pods",
      "services",
      "configmaps",
      "secrets",
      "events",
      "persistentvolumeclaims",
      "pods/log",
      "namespaces"
    ]
  }

  rule {
    verbs = ["get"]
    api_groups = [
      "extensions",
      "networking.k8s.io"
    ]
    resources = ["ingresses"]
  }

  rule {
    verbs = ["*"]
    api_groups = ["networking.istio.io"]
    resources = ["virtualservices"]
  }

  rule {
    verbs = ["get"]
    api_groups = [""]
    resources = ["nodes"]
  }

  rule {
    verbs = ["get", "list", "watch"]
    api_groups = [""]
    resources = ["resourcequotas"]
  }

  rule {
    verbs = ["create", "get", "update", "delete"]
    api_groups = ["apiextensions.k8s.io"]
    resources = ["customresourcedefinitions"]
  }

  rule {
    verbs = ["create", "get", "update", "delete"]
    api_groups = ["admissionregistration.k8s.io"]
    resources = [
      "mutatingwebhookconfigurations",
      "validatingwebhookconfigurations"
    ]
  }

  rule {
    verbs = ["*"]
    api_groups = ["sparkoperator.k8s.io"]
    resources = [
      "*",
      "sparkapplications",
      "sparkapplications/status",
      "scheduledsparkapplications",
      "scheduledsparkapplications/status"
    ]
  }

  rule {
    verbs = ["*"]
    api_groups = ["helm.toolkit.fluxcd.io"]
    resources = ["*"]
  }

  rule {
    verbs = ["delete"]
    api_groups = ["batch"]
    resources = ["jobs"]
  }

  rule {
    verbs = ["*"]
    api_groups = ["rbac.authorization.k8s.io"]
    resources = [
      "roles",
      "rolebindings"
    ]
  }

  rule {
    verbs = ["get", "list", "watch"]
    api_groups = ["events.k8s.io"]
    resources = ["events"]
  }

  rule {
    verbs = ["create", "get", "update", "delete"]
    api_groups = [""]
    resources = [
      "services",
      "configmaps",
      "secrets",
      "events",
      "nodes",
      "resourcequotas"
    ]
  }

  rule {
    verbs = ["create", "get", "delete"]
    api_groups = [
      "extensions",
      "networking.k8s.io"
    ]
    resources = ["ingresses"]
  }

  rule {
    verbs = ["create", "update", "patch"]
    api_groups = [""]
    resources = ["events"]
  }

  rule {
    verbs = ["*"]
    api_groups = [
      "scheduling.incubator.k8s.io",
      "scheduling.sigs.dev",
      "scheduling.volcano.sh"
    ]
    resources = ["podgroups"]
  }

  rule {
    verbs = ["create", "get", "list", "watch", "update", "patch"]
    api_groups = ["coordination.k8s.io"]
    resources = ["leases"]
  }
}

resource "kubernetes_role_binding" "iomete_lakehouse_role_binding" {
  metadata {
    name = "iomete-lakehouse-role-binding"
    namespace = var.namespace
  }

  role_ref {
    kind     = "Role"
    name     = kubernetes_role.iomete_lakehouse_role.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account.lakehouse_service_account.metadata[0].name
    namespace = ""
  }
}

