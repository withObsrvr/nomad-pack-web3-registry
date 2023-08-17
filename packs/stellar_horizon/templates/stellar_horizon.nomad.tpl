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
        to = 8000
      }
      port "db" {
        static = 5432
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

    task "postgres" {
      driver = "docker"

      volume_mount {
        volume      = "postgresql"
        destination = "/var/lib/postgresql/data"
        read_only   = false
      }

      config {
        image = "postgres:[[ .stellar_horizon.db_image_tag ]]"
    


        auth {
          username = "[[ .stellar_horizon.db_dockerhub_username ]]"
          password = "[[ .stellar_horizon.db_dockerhub_password ]]"
        }

      }
      env {
          POSTGRES_USER="[[ .stellar_horizon.db_user ]]"
          POSTGRES_PASSWORD="[[ .stellar_horizon.db_password ]]"
          POSTGRES_DB="[[ .stellar_horizon.db_name ]]"
      }

      logs {
        max_files     = 5
        max_file_size = 15
      }

      resources {
        cpu = [[ .stellar_horizon.db_task_resources.cpu ]]
        memory = [[ .stellar_horizon.db_task_resources.memory ]]
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
        image = "stellar/stellar-horizon:[[ .stellar_horizon.image_tag ]]"
        ports = ["http"]
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
      UNSAFE_QUORUM=true
      [[`[[HOME_DOMAINS]]`]]
      HOME_DOMAIN="futurenet.stellar.org"
      QUALITY="MEDIUM"

      [[`[[VALIDATORS]]`]]
      NAME="sdf_futurenet_1"
      HOME_DOMAIN="futurenet.stellar.org"
      PUBLIC_KEY="GBRIF2N52GVN3EXBBICD5F4L5VUFXK6S6VOUCF6T2DWPLOLGWEPPYZTF"
      ADDRESS="core-live-futurenet.stellar.org:11625"
      HISTORY="curl -sf http://history-futurenet.stellar.org/{0} -o {1}"
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
