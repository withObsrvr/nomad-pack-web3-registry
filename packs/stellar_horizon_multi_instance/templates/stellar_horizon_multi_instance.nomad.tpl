job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .stellar_horizon_multi_instance.datacenters  | toJson ]]
  type        = "service"
  [[ template "namespace" . ]]

  group [[ template "job_name" . ]] {
    count = [[ .stellar_horizon_multi_instance.count ]]

    network {
      mode = "host"
      port "http" {
        to = [[ .stellar_horizon_multi_instance.http_port ]]
      }
      port "core1" {
        to = [[ .stellar_horizon_multi_instance.core1_port ]]
      }
      port "core2" {
        to = [[ .stellar_horizon_multi_instance.core2_port ]]
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
        image = "[[ .stellar_horizon_multi_instance.image_repo ]]:[[ .stellar_horizon_multi_instance.image_tag ]]"
        ports = ["http", "core1", "core2"]
        args  = [[ .stellar_horizon_multi_instance.image_args | toJson ]]

        auth {
          username = "${DOCKERHUB_USERNAME}"
          password = "${DOCKERHUB_PASSWORD}"
        }
      }
      template {
        data        = <<EOF
      {{ range nomadService "[[ .stellar_horizon_multi_instance.db_service_name ]]" }}
      DATABASE_URL="postgresql://[[ .stellar_horizon_multi_instance.db_user ]]:[[ .stellar_horizon_multi_instance.db_password ]]@{{ .Address }}:{{ .Port }}/[[ .stellar_horizon_multi_instance.db_name ]]?sslmode=disable"
      NETWORK_PASSPHRASE="[[ .stellar_horizon_multi_instance.network_passphrase ]]"
      HISTORY_ARCHIVE_URLS="[[ .stellar_horizon_multi_instance.history_archive_urls ]]"
      STELLAR_CORE_BINARY_PATH="/usr/bin/stellar-core"
      CAPTIVE_CORE_CONFIG_PATH="local/stellar_captive_core.cfg"
      HISTORY_RETENTION_COUNT="[[ .stellar_horizon_multi_instance.history_retention_count ]]"
      {{ end }}
      APPLY_MIGRATIONS=[[ .stellar_horizon_multi_instance.apply_migrations ]]
      DISABLE_TX_SUB=[[ .stellar_horizon_multi_instance.disable_tx_sub ]]
      INGEST="[[ .stellar_horizon_multi_instance.ingest ]]"
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
      [[ .stellar_horizon_multi_instance.captive_core_cfg ]]  
        EOF
        destination = "local/stellar_captive_core.cfg"
      }

      resources {
        cpu    = [[ .stellar_horizon_multi_instance.task_resources.cpu ]]
        memory = [[ .stellar_horizon_multi_instance.task_resources.memory ]]
      }
      [[ if .stellar_horizon_multi_instance.register_service ]]
      service {
        name = "[[ .stellar_horizon_multi_instance.registered_service_name ]]"
        port = "http"
        provider = "[[ .stellar_horizon_multi_instance.service_registration_provider ]]"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }

        tags = [[ .stellar_horizon_multi_instance.service_tags | toJson ]]
      }
      [[ end ]]
    }
  }
}
