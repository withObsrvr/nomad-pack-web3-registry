job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .stellar_horizon.datacenters  | toJson ]]
  type        = "service"
  [[ template "namespace" . ]]

  group [[ template "job_name" . ]] {
    count = [[ .stellar_horizon.count ]]

    network {
      mode = "host"
      port "http" {
        static = 8000
      }
      port "core1" {
        static = [[ .stellar_horizon.core1_port ]]
      }
      port "core2" {
        static = [[ .stellar_horizon.core2_port ]]
      }
    }

    volume "postgresql" {
      type      = "host"
      read_only = false
      source    = "postgresql"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }


    task [[ template "job_name" . ]] {
      driver = "docker"
      
      config {
        image = "[[ .stellar_horizon.image_repo ]]:[[ .stellar_horizon.image_tag ]]"
        ports = ["http", "core1", "core2"]
        args  = [[ .stellar_horizon.image_args | toJson ]]

        auth {
          username = "${DOCKERHUB_USERNAME}"
          password = "${DOCKERHUB_PASSWORD}"
        }
      }
      template {
        data        = <<EOF
      {{ range nomadService "postgres" }}
      DATABASE_URL="postgresql://[[ .stellar_horizon.db_user ]]:[[ .stellar_horizon.db_password ]]@{{ .Address }}:{{ .Port }}/[[ .stellar_horizon.db_name ]]?sslmode=disable"
      NETWORK_PASSPHRASE="[[ .stellar_horizon.network_passphrase ]]"
      HISTORY_ARCHIVE_URLS="[[ .stellar_horizon.history_archive_urls ]]"
      STELLAR_CORE_BINARY_PATH="/usr/bin/stellar-core"
      CAPTIVE_CORE_CONFIG_PATH="local/stellar_captive_core.cfg"
      HISTORY_RETENTION_COUNT="[[ .stellar_horizon.history_retention_count ]]"
      {{ end }}
      APPLY_MIGRATIONS=[[ .stellar_horizon.apply_migrations ]]
      DISABLE_TX_SUB=[[ .stellar_horizon.disable_tx_sub ]]
      INGEST="[[ .stellar_horizon.ingest ]]"
        EOF
        destination = "local/env.txt"
        env         = true
      }
      template {
        data = <<EOF
      {{ with nomadVar "nomad/jobs/[[ template "nomadvar_job_name" . ]]" }}
      DOCKERHUB_USERNAME = {{ .dockerhub_username }}
      DOCKERHUB_PASSWORD = {{ .dockerhub_password }}
      {{ end }}
        EOF
        destination = "${NOMAD_SECRETS_DIR}/env.vars"
        env         = true
      }
      template {
        data = <<EOF
      [[ .stellar_horizon.captive_core_cfg ]]  
        EOF
        destination = "local/stellar_captive_core.cfg"
      }

      resources {
        cpu    = [[ .stellar_horizon.task_resources.cpu ]]
        memory = [[ .stellar_horizon.task_resources.memory ]]
      }
      [[ if .stellar_horizon.register_service ]]
      service {
        name = "[[ .stellar_horizon.registered_service_name ]]"
        port = "http"
        provider = "[[ .stellar_horizon.service_registration_provider ]]"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }

        tags = [[ .stellar_horizon.service_tags | toJson ]]
      }
      [[ end ]]
    }
  }
}