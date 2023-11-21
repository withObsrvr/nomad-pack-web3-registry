job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .stellar_anchor_platform.datacenters  | toJson ]]
  type        = "service"
  [[ template "namespace" . ]]

  group [[ template "job_name" . ]] {
    count = [[ .stellar_anchor_platform.count ]]

    network {
      mode = "host"
      port "sephttp" {
        static = 8080
      }
      port "platformhttp" {
        static = 8085
      }
    }

    volume "anchorhome" {
      type      = "host"
      read_only = false
      source    = "anchorhome"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task [[ .stellar_anchor_platform.sep_job_name ]] {
      driver = "docker"

      volume_mount {
        volume      = "anchorhome"
        destination = "/home"
        read_only   = false
      }

      config {
        image = "stellar/anchor-platform:[[ .stellar_anchor_platform.sep_image_tag ]]"
        network_mode = "host"
        args  = [[ .stellar_anchor_platform.sep_image_args | toJson ]]
    


        auth {
          username = "[[ .stellar_anchor_platform.db_dockerhub_username ]]"
          password = "[[ .stellar_anchor_platform.db_dockerhub_password ]]"
        }

      }
      env {
          POSTGRES_USER="[[ .stellar_anchor_platform.db_user ]]"
          POSTGRES_PASSWORD="[[ .stellar_anchor_platform.db_password ]]"
          POSTGRES_DB="[[ .stellar_anchor_platform.db_name ]]"
      }

      logs {
        max_files     = 5
        max_file_size = 15
      }

      resources {
        cpu = [[ .stellar_anchor_platform.db_task_resources.cpu ]]
        memory = [[ .stellar_anchor_platform.db_task_resources.memory ]]
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
        image = "stellar/anchor-platform:[[ .stellar_anchor_platform.platform_image_tag ]]"
        ports = ["http"]
        args  = [[ .stellar_anchor_platform.platform_image_args | toJson ]]

        auth {
          username = "${DOCKERHUB_USERNAME}"
          password = "${DOCKERHUB_PASSWORD}"
        }
      }
      template {
        data        = <<EOF
      {{ range nomadService "postgres" }}
      DATABASE_URL="postgresql://[[ .stellar_anchor_platform.db_user ]]:[[ .stellar_anchor_platform.db_password ]]@{{ .Address }}:{{ .Port }}/[[ .stellar_anchor_platform.db_name ]]?sslmode=disable"
      NETWORK_PASSPHRASE="[[ .stellar_anchor_platform.network_passphrase ]]"
      HISTORY_ARCHIVE_URLS="[[ .stellar_anchor_platform.history_archive_urls ]]"
      STELLAR_CORE_BINARY_PATH="/usr/bin/stellar-core"
      CAPTIVE_CORE_CONFIG_PATH="local/stellar_captive_core.cfg"
      HISTORY_RETENTION_COUNT="[[ .stellar_anchor_platform.history_retention_count ]]"
      {{ end }}
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
      [[ .stellar_anchor_platform.captive_core_cfg ]]  
        EOF
        destination = "local/stellar_captive_core.cfg"
      }

      resources {
        cpu    = [[ .stellar_anchor_platform.task_resources.cpu ]]
        memory = [[ .stellar_anchor_platform.task_resources.memory ]]
      }
      [[ if .stellar_anchor_platform.register_service ]]
      service {
        name = "[[ .stellar_anchor_platform.registered_service_name ]]"
        port = "http"
        provider = "[[ .stellar_anchor_platform.service_registration_provider ]]"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }

        tags = [[ .stellar_anchor_platform.service_tags | toJson ]]
      }
      [[ end ]]
    }
  }
}
