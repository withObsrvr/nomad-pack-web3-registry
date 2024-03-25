job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .opensearch.datacenters  | toJson ]]
  type        = "service"
  [[ template "namespace" . ]]

  group [[ template "job_name" . ]] {
    count = [[ .opensearch.count ]]

    network {
      mode = "host"
      port "http" {
        static = 9200
      }
      port "db" {
        static = 9600
      }
      port "core1" {
        static = 5601
      }
      port "core2" {
        static = [[ .opensearch.core2_port ]]
      }
      port "admin" {
        static = [[ .opensearch.admin_port ]]
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

    task [[ .opensearch.db_job_name ]] {
      driver = "docker"

      volume_mount {
        volume      = "postgresql"
        destination = "/var/lib/postgresql/data"
        read_only   = false
      }

      config {
        image = "postgres:[[ .opensearch.db_image_tag ]]"
        ports = ["db"]

    


        auth {
          username = "[[ .opensearch.db_dockerhub_username ]]"
          password = "[[ .opensearch.db_dockerhub_password ]]"
        }

      }
      env {
          POSTGRES_USER="[[ .opensearch.db_user ]]"
          POSTGRES_PASSWORD="[[ .opensearch.db_password ]]"
          POSTGRES_DB="[[ .opensearch.db_name ]]"
      }

      logs {
        max_files     = 5
        max_file_size = 15
      }

      resources {
        cpu = [[ .opensearch.db_task_resources.cpu ]]
        memory = [[ .opensearch.db_task_resources.memory ]]
      }
      service {
        name = "postgres"
        tags = ["postgres"]
        port = "db"
        provider = "nomad"

        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }

    task [[ template "job_name" . ]] {
      driver = "docker"
      


      config {
        image = "[[ .opensearch.image_repo ]]:[[ .opensearch.image_tag ]]"
        ports = ["http", "core1", "core2", "admin"]
        args  = [[ .opensearch.image_args | toJson ]]

        auth {
          username = "${DOCKERHUB_USERNAME}"
          password = "${DOCKERHUB_PASSWORD}"
        }
      }
      template {
        data        = <<EOF
      {{ range nomadService "postgres" }}
      DATABASE_URL="postgresql://[[ .opensearch.db_user ]]:[[ .opensearch.db_password ]]@{{ .Address }}:{{ .Port }}/[[ .opensearch.db_name ]]?sslmode=disable"
      NETWORK_PASSPHRASE="[[ .opensearch.network_passphrase ]]"
      HISTORY_ARCHIVE_URLS="[[ .opensearch.history_archive_urls ]]"
      STELLAR_CORE_BINARY_PATH="/usr/bin/stellar-core"
      CAPTIVE_CORE_CONFIG_PATH="local/stellar_captive_core.cfg"
      HISTORY_RETENTION_COUNT="[[ .opensearch.history_retention_count ]]"
      {{ end }}
      ADMIN_PORT=[[ .opensearch.admin_port ]]
      APPLY_MIGRATIONS=[[ .opensearch.apply_migrations ]]
      DISABLE_TX_SUB=[[ .opensearch.disable_tx_sub ]]
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
      {{ if .opensearch.admin_port_enable }}
      ADMIN_PORT=[[ .opensearch.admin_port ]]
      {{ end }}
        EOF
        destination = "${NOMAD_SECRETS_DIR}/env.vars"
        env         = true
      }
      template {
        data = <<EOF
      [[ .opensearch.captive_core_cfg ]]  
        EOF
        destination = "local/stellar_captive_core.cfg"
      }

      resources {
        cpu    = [[ .opensearch.task_resources.cpu ]]
        memory = [[ .opensearch.task_resources.memory ]]
      }
      [[ if .opensearch.register_service ]]
      service {
        name = "[[ .opensearch.registered_service_name ]]"
        port = "http"
        provider = "[[ .opensearch.service_registration_provider ]]"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }

        tags = [[ .opensearch.service_tags | toJson ]]
      }
      [[ end ]]
      [[ if .opensearch.admin_port_enable ]]
      service {
        name = "[[ .opensearch.registered_service_name ]]-admin"
        port = "admin"
        provider = "[[ .opensearch.service_registration_provider ]]"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }

        tags = [[ .opensearch.admin_service_tags | toJson ]]
      }
      [[ end ]]
    }
  }
}
