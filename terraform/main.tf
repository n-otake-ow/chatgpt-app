data "google_project" "project" {
}

resource "google_artifact_registry_repository" "this" {
  location      = var.location
  repository_id = local.app.name
  format        = "DOCKER"
}

resource "google_secret_manager_secret" "this" {
  for_each  = { for s in local.secrets : s.name => s.value }
  secret_id = each.key
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "this" {
  for_each = { for s in local.secrets : s.name => s.value }

  secret      = google_secret_manager_secret.this[each.key].id
  secret_data = each.value
}

resource "google_secret_manager_secret_iam_member" "this" {
  for_each  = { for s in local.secrets : s.name => s.value }
  secret_id = each.key
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

resource "google_cloud_run_service" "this" {
  location = var.location
  name     = local.app.name
  template {
    spec {
      containers {
        image = "asia-northeast1-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.this.name}/${local.cloud_run.image_name}:${local.cloud_run.image_tag}"
        ports {
          container_port = 8501
        }
        resources {
          limits = {
            cpu    = "1"
            memory = "512Mi"
          }
        }
        dynamic "env" {
          for_each = { for s in local.secrets : s.name => s.value }
          content {
            name = env.key
            value_from {
              secret_key_ref {
                key  = "latest"
                name = env.key
              }
            }
          }
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "0"
        "autoscaling.knative.dev/maxScale" = "5"
      }
    }
  }
}

data "google_iam_policy" "public" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "public" {
  location = google_cloud_run_service.this.location
  project  = google_cloud_run_service.this.project
  service  = google_cloud_run_service.this.name

  policy_data = data.google_iam_policy.public.policy_data
}
