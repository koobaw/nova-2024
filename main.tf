# 配置Google提供者
provider "google" {
  project = "nova-d"
  region  = "us-central1"
}

# 创建服务账号
resource "google_service_account" "adozoo_cc" {
  account_id   = "adozoo-cc"
  display_name = "adozoo.cc Service Account"
}

# 为服务账号赋予Editor角色
resource "google_project_iam_member" "adozoo_cc_editor" {
  project = "nova-d"
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.adozoo_cc.email}"
}

# 创建Pub/Sub主题
resource "google_pubsub_topic" "test1" {
  name = "test1"
}

# 创建Cloud Run服务
resource "google_cloud_run_service" "test1" {
  name     = "test1"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello" # 使用GCP自带的通用镜像
      }
      service_account_name = google_service_account.adozoo_cc.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# 授权Cloud Run服务访问Pub/Sub
resource "google_project_iam_member" "pubsub_invoker" {
  project = "nova-d"
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.adozoo_cc.email}"
}

