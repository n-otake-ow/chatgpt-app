resource "google_artifact_registry_repository" "this" {
  location      = var.location
  repository_id = local.app.name
  format        = "DOCKER"
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
            cpu    = "1000m"
            memory = "512Mi"
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

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.this.location
  project  = google_cloud_run_service.this.project
  service  = google_cloud_run_service.this.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
