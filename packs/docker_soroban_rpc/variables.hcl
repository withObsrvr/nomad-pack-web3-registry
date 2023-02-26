variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
  default     = ""
}

variable "namespace" {
  description = "The namespace to deploy the job into"
  type        = string
  default     = ""
}

variable "region" {
  description = "The region where jobs will be deployed"
  type        = string
  default     = ""
}

variable "count" {
  description = "The number of app instances to deploy"
  type        = number
  default     = 1
}

variable "image_tag" {
  description = "The image tag to use for the app"
  type        = string
  default     = "latest"
}

variable "image_args" {
  description = "The arguments to pass to the app"
  type        = list(string)
  default     = [
    "--endpoint=0.0.0.0:8000",
    "--log-level=info",
    "--network-passphrase='Test SDF Future Network ; October 2022'"
  ]
}

variable "datacenters" {
  description = "A list of datacenters that are eligible for task placement"
  type        = list(string)
  default     = ["dc1"]
}

variable "register_service" {
  description = "If you want to register a nomad or consul service for the job"
  type        = bool
  default     = true
}

variable "service_registration_provider" {
  description = "The service registration provider to use. Valid values are 'nomad' or 'consul'"
  type        = string
  default     = "nomad"
}

variable "registered_service_name" {
  description = "The service name for the Stellar Quickstart service"
  type        = string
  default     = "webapp"
}

variable "service_tags" {
  description = "A list of tags to register with the service"
  type        = list(string)
  // defaults to integrate with Traefik
  // This routes at the root path "/", to route to this service from
  // another path, change "urlprefix-/" to "urlprefix-/<PATH>" and
  // "traefik.http.routers.http.rule=Path(`/`)" to
  // "traefik.http.routers.http.rule=Path(`/<PATH>`)"
  default     = [
    "urlprefix-/",
    "traefik.enable=true",
    "traefik.http.routers.http.rule=Path(`/`)",
  ]
}

variable "task_resources" {
  description = "The resource to assign to the Stellar Quickstart task."
  type        = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 1000,
    memory = 2000,
  }
}