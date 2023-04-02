variable "project_id" {
  type        = string
  description = "Google Cloud project ID"
}

variable "location" {
  type        = string
  description = "Google Cloud location"
  default     = "asia-northeast1"
}

variable "credentials_path" {
  type        = string
  description = "Path to Google Cloud credentials file"
}

variable "openai_api_key" {
  type        = string
  description = "OpenAI API key"
}
