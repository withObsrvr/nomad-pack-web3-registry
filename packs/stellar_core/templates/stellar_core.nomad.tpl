job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .stellar_core.datacenters  | toJson ]]
  type        = "service"
  [[ template "namespace" . ]]

  group [[ template "job_name" . ]] {
    count = [[ .stellar_core.count ]]



    network {
      mode = "host"
      port "http" {
        static = 11625
      }

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
        image = "[[ .stellar_core.image_repo ]]:[[ .stellar_core.image_tag ]]"
        ports = ["http"]
        args  = [[ .stellar_core.image_args | toJson ]]

        auth {
          username = "${DOCKERHUB_USERNAME}"
          password = "${DOCKERHUB_PASSWORD}"
        }
      }
      template {
        data        = <<EOF
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
      [[ .stellar_core.captive_core_cfg ]]  
        EOF
        destination = "local/stellar_captive_core.cfg"
      }

      resources {
        cpu    = [[ .stellar_core.task_resources.cpu ]]
        memory = [[ .stellar_core.task_resources.memory ]]
      }
      [[ if .stellar_core.register_service ]]
      service {
        name = "[[ .stellar_core.registered_service_name ]]"
        port = "http"
        provider = "[[ .stellar_core.service_registration_provider ]]"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }

        tags = [[ .stellar_core.service_tags | toJson ]]
      }
      [[ end ]]
    }
  }
}
