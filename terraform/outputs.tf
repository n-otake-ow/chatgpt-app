output "url" {
  value = [for s in google_cloud_run_service.this.status : s.url]
}
