job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .stellar_quickstart.datacenters  | toJson ]]
  type        = "service"
  [[ template "namespace" . ]]

  group [[ template "job_name" . ]] {
    count = [[ .stellar_quickstart.count ]]

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task [[ template "job_name" . ]] {
      driver = "docker"
      


      config {
        image = "stellar/quickstart:[[ .stellar_quickstart.image_tag ]]"
        ports = ["http"]
        args  = [[ .stellar_quickstart.image_args | toJson ]]

        auth {
          username = "${DOCKERHUB_USERNAME}"
          password = "${DOCKERHUB_PASSWORD}"
        }
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

      resources {
        cpu    = [[ .stellar_quickstart.task_resources.cpu ]]
        memory = [[ .stellar_quickstart.task_resources.memory ]]
      }
      [[ if .stellar_quickstart.register_service ]]
      service {
        name = "[[ .stellar_quickstart.registered_service_name ]]"
        port = "http"
        provider = "[[ .stellar_quickstart.service_registration_provider ]]"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }

        tags = [[ .stellar_quickstart.service_tags | toJson ]]
      }
      [[ end ]]
    }
    network {
      port "http" {
        to = 8000
      }
    }
  }
}
