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

variable "captive_core_cfg" {
  description = "The config to use for the captive core"
  type        = string
  default     = ""
}

variable "environment" {
  description = "The stellar environment to deploy the job into"
  type        = string
  default     = "testnet"
}

variable "http_port" {
  description = "The port to use for the app"
  type        = number
  default     = 8000
}

variable "core1_port" {
  description = "The port to use for the first core instance"
  type        = number
  default     = 11626
}

variable "core2_port" {
  description = "The port to use for the second core instance"
  type        = number
  default     = 11625
}

variable "count" {
  description = "The number of app instances to deploy"
  type        = number
  default     = 1
}

variable "image_repo" {
  description = "The image repository to use for the app"
  type        = string
  default     = "stellar/stellar-horizon"
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

variable "network_passphrase" {
  description = "The network passphrase to use for the app"
  type        = string
  default     = "Test SDF Network ; September 2015"
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
  description = "The service name for the Stellar Horizon service"
  type        = string
  default     = "webapp"
}

variable "ingest_service_name" {
  description = "The service name for the Stellar Horizon service"
  type        = string
  default     = "horizon-ingest"
}

variable "db_service_name" {
  description = "The service name for the Stellar Horizon database"
  type        = string
  default     = "postgres"
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
  description = "The resource to assign to the Stellar Horizon task."
  type        = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 1000,
    memory = 2000,
  }
}



variable "history_archive_urls" {
  description = "A list of history archive urls to use for the app"
  type        = string
  default     = "https://history.stellar.org/prd/core-testnet/core_testnet_001,https://history.stellar.org/prd/core-testnet/core_testnet_002"
}

variable "history_retention_count" {
  description = "The number of ledgers to retain in history archives"
  type        = number
  default     = 43200
}

variable "apply_migrations" {
  description = "If you want to apply migrations to the database"
  type        = bool
  default     = false
}

variable "disable_tx_sub" {
  description = "If you want to disable the transaction submission"
  type        = bool
  default     = true
}

variable "ingest" {
  description = "If you want to ingest the history"
  type        = bool
  default     = true
}

variable "db_user" {
    description = "The database user to use for the app"
    type        = string
    default     = "postgres"
}

variable "db_password" {
    description = "The database password to use for the app"
    type        = string
    default     = "postgres"
}

variable "db_name" {
    description = "The database name to use for the app"
    type        = string
    default     = "postgres"
}

variable "network" {
    description = "The network to use for the app"
    type        = string
    default     = "testnet"
}