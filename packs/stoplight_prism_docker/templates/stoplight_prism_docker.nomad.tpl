job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .stoplight_prism_docker.datacenters  | toJson ]]
  type        = "service"
  [[ template "namespace" . ]]

  group [[ template "job_name" . ]] {
    count = [[ .stoplight_prism_docker.count ]]

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task [[ template "job_name" . ]] {
      driver = "docker"
      


      config {
        image = "stoplight/prism:[[ .stoplight_prism_docker.image_tag ]]"
        ports = ["http"]
        args  = [[ .stoplight_prism_docker.image_args | toJson ]]

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
        cpu    = [[ .stoplight_prism_docker.task_resources.cpu ]]
        memory = [[ .stoplight_prism_docker.task_resources.memory ]]
      }
      [[ if .stoplight_prism_docker.register_service ]]
      service {
        name = "[[ .stoplight_prism_docker.registered_service_name ]]"
        port = "http"
        provider = "[[ .stoplight_prism_docker.service_registration_provider ]]"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }

        tags = [[ .stoplight_prism_docker.service_tags | toJson ]]
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
