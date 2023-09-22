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
        ports = ["http"]
        args  = [[ .docker_soroban_rpc.image_args | toJson ]]

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
      [[`[[HOME_DOMAINS]]`]]
      HOME_DOMAIN="testnet.stellar.org"
      QUALITY="HIGH"

      [[`[[VALIDATORS]]`]]
      NAME="sdf_testnet_1"
      HOME_DOMAIN="testnet.stellar.org"
      PUBLIC_KEY="GDKXE2OZMJIPOSLNA6N6F2BVCI3O777I2OOC4BV7VOYUEHYX7RTRYA7Y"
      ADDRESS="core-testnet1.stellar.org"
      HISTORY="curl -sf http://history.stellar.org/prd/core-testnet/core_testnet_001/{0} -o {1}"

      [[`[[VALIDATORS]]`]]
      NAME="sdf_testnet_2"
      HOME_DOMAIN="testnet.stellar.org"
      PUBLIC_KEY="GCUCJTIYXSOXKBSNFGNFWW5MUQ54HKRPGJUTQFJ5RQXZXNOLNXYDHRAP"
      ADDRESS="core-testnet2.stellar.org"
      HISTORY="curl -sf http://history.stellar.org/prd/core-testnet/core_testnet_002/{0} -o {1}"

      [[`[[VALIDATORS]]`]]
      NAME="sdf_testnet_3"
      HOME_DOMAIN="testnet.stellar.org"
      PUBLIC_KEY="GC2V2EFSXN6SQTWVYA5EPJPBWWIMSD2XQNKUOHGEKB535AQE2I6IXV2Z"
      ADDRESS="core-testnet3.stellar.org"
      HISTORY="curl -sf http://history.stellar.org/prd/core-testnet/core_testnet_003/{0} -o {1}"
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
      [[ end ]]
    }
    network {
      port "http" {
        to = 8000
      }
    }
  }
}
