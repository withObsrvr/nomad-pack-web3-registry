job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .postgres_horizon.datacenters  | toJson ]]
  type        = "service"
  [[ template "namespace" . ]]

  group [[ template "job_name" . ]] {
    count = [[ .postgres_horizon.count ]]

    network {
      mode = "host"
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

    task [[ .postgres_horizon.db_job_name ]] {
      driver = "docker"

      volume_mount {
        volume      = "postgresql"
        destination = "/var/lib/postgresql/data"
        read_only   = false
      }

      config {
        image = "postgres:[[ .postgres_horizon.db_image_tag ]]"
        network_mode = "host"
    


        auth {
          username = "[[ .postgres_horizon.db_dockerhub_username ]]"
          password = "[[ .postgres_horizon.db_dockerhub_password ]]"
        }

      }
      env {
          POSTGRES_USER="[[ .postgres_horizon.db_user ]]"
          POSTGRES_PASSWORD="[[ .postgres_horizon.db_password ]]"
          POSTGRES_DB="[[ .postgres_horizon.db_name ]]"
      }

      logs {
        max_files     = 5
        max_file_size = 15
      }

      resources {
        cpu = [[ .postgres_horizon.db_task_resources.cpu ]]
        memory = [[ .postgres_horizon.db_task_resources.memory ]]
      }
      service {
        name = "[[ .postgres_horizon.service_name ]]"
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
  }
}
