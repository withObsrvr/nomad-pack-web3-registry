job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .docker_soroban_rpc.datacenters  | toJson ]]
  type        = "service"
  [[ template "namespace" . ]]

  group [[ template "job_name" . ]] {
    count = [[ .docker_soroban_rpc.count ]]

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

  

    task [[ template "job_name" . ]] {
      driver = "docker"
      


      config {
        image = "stellar/soroban-rpc:[[ .docker_soroban_rpc.image_tag ]]"
        ports = ["http", "admin"]
        args  = [[ .docker_soroban_rpc.image_args | toJson ]]

        auth {
          username = "${DOCKERHUB_USERNAME}"
          password = "${DOCKERHUB_PASSWORD}"
        }
      }
      template {
        data        = <<EOF
      NETWORK_PASSPHRASE="[[ .docker_soroban_rpc.network_passphrase ]]"
      HISTORY_ARCHIVE_URLS="[[ .docker_soroban_rpc.history_archive_urls ]]"
      STELLAR_CORE_BINARY_PATH="/usr/bin/stellar-core"
      CAPTIVE_CORE_CONFIG_PATH="local/stellar_captive_core.cfg"
      DEPRECATED_SQL_LEDGER_STATE="[[ .docker_soroban_rpc.deprecated_sql_ledger_state ]]"
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
      [[ .docker_soroban_rpc.captive_core_cfg ]]  
        EOF
        destination = "local/stellar_captive_core.cfg"
      }

      resources {
        cpu    = [[ .docker_soroban_rpc.task_resources.cpu ]]
        memory = [[ .docker_soroban_rpc.task_resources.memory ]]
      }
      [[ if .docker_soroban_rpc.register_service ]]
      service {
        name = "[[ .docker_soroban_rpc.registered_service_name ]]"
        port = "http"
        provider = "[[ .docker_soroban_rpc.service_registration_provider ]]"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }

        tags = [[ .docker_soroban_rpc.service_tags | toJson ]]
      }
      service {
        name = "[[ .docker_soroban_rpc.registered_service_name ]]-admin"
        port = "admin"
        provider = "[[ .docker_soroban_rpc.service_registration_provider ]]"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }

        tags = [[ .docker_soroban_rpc.admin_service_tags | toJson ]]
      }
      [[ end ]]
    }
    network {
      port "http" {
        static = [[ .docker_soroban_rpc.http_port ]]
      }
      port "admin" {
        static = [[ .docker_soroban_rpc.admin_port ]]
      }
    }
  }
}
