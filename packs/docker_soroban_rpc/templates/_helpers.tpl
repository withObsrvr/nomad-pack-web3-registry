// Set the job name

[[ define "job_name" ]]
[[- if eq .docker_soroban_rpc.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .docker_soroban_rpc.job_name | quote -]]
[[- end ]]
[[- end ]]

// Set the job name

[[ define "nomadvar_job_name" ]]
[[- if eq .docker_soroban_rpc.job_name "" -]]
[[- .nomad_pack.pack.name  -]]
[[- else -]]
[[- .docker_soroban_rpc.job_name  -]]
[[- end ]]
[[- end ]]

// only deploys to a region if specified

[[ define "region" -]]
[[- if not (eq .docker_soroban_rpc.region "") -]]
  region = [[ .docker_soroban_rpc.region | quote]]
[[- end -]]
[[- end -]]

// only deploys to a namespace if specified

[[ define "namespace" -]]
[[- if not (eq .docker_soroban_rpc.namespace "") -]]
  namespace = [[ .docker_soroban_rpc.namespace | quote]]
[[- end -]]
[[- end -]]