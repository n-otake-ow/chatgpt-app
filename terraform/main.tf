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

resource "google_service_account" "this" {
  account_id   = "${local.app.name}-sa"
  display_name = "Service Account for the app"
}

resource "google_secret_manager_secret_iam_member" "this" {
  for_each  = { for s in local.secrets : s.name => s.value }
  secret_id = each.key
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.this.email}"
  depends_on = [
    google_secret_manager_secret.this,
    google_service_account.this,
  ]
}

resource "google_cloud_run_v2_service" "this" {
  location = var.location
  name     = local.app.name
  template {
    service_account = google_service_account.this.email
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
          value_source {
            secret_key_ref {
              version = "latest"
              secret  = env.key
            }
          }
        }
      }
    }

    annotations = {
      "autoscaling.knative.dev/minScale" = "0"
      "autoscaling.knative.dev/maxScale" = "5"
    }
  }

  depends_on = [
    google_secret_manager_secret_iam_member.this,
  ]
}

data "google_iam_policy" "public" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "public" {
  location = google_cloud_run_v2_service.this.location
  project  = google_cloud_run_v2_service.this.project
  service  = google_cloud_run_v2_service.this.name

  policy_data = data.google_iam_policy.public.policy_data
}

resource "google_bigquery_dataset" "this" {
  dataset_id = replace(local.app.name, "-", "_")
  location   = var.location
}

resource "google_bigquery_table" "query_log" {
  dataset_id          = google_bigquery_dataset.this.dataset_id
  table_id            = "query_log"
  deletion_protection = true

  schema = jsonencode([
    {
      name = "language"
      type = "STRING"
    },
    {
      name = "word"
      type = "STRING"
    },
    {
      name = "id"
      type = "STRING"
    },
    {
      name = "object"
      type = "STRING"
    },
    {
      name = "created"
      type = "TIMESTAMP"
    },
    {
      name = "model"
      type = "STRING"
    },
    {
      name = "choices"
      type = "RECORD"
      mode = "REPEATED"
      fields = [
        {
          name = "index"
          type = "INTEGER"
          mode = "NULLABLE"
        },
        {
          name = "message"
          type = "RECORD"
          fields = [
            {
              name = "role"
              type = "STRING"
            },
            {
              name = "content"
              type = "STRING"
            },
          ]
        },
        {
          name = "finish_reason"
          type = "STRING"
        },
      ]
    },
    {
      name = "usage"
      type = "RECORD"
      fields = [
        {
          name = "prompt_tokens"
          type = "INTEGER"
        },
        {
          name = "completion_tokens"
          type = "INTEGER"
        },
        {
          name = "total_tokens"
          type = "INTEGER"
        }
      ]
    },
  ])

  depends_on = [
    google_bigquery_dataset.this,
  ]
}
