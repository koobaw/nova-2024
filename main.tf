provider "google" {
  project = "nova-d"
  region  = "us-central1"
}

resource "google_service_account" "adozoo_cc" {
  account_id   = "adozoo-cc"
  display_name = "adozoo.cc Service Account"
}

resource "google_project_iam_member" "adozoo_cc_editor" {
  project = "nova-d"
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.adozoo_cc.email}"
}

resource "google_pubsub_topic" "test1" {
  name = "test1"
}

resource "google_cloud_run_service" "test1" {
  name     = "test1"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
      }
      service_account_name = google_service_account.adozoo_cc.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_project_iam_member" "pubsub_invoker" {
  project = "nova-d"
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.adozoo_cc.email}"
}

