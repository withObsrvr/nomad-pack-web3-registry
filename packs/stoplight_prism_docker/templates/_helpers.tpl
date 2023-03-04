// Set the job name

[[ define "job_name" ]]
[[- if eq .stoplight_prism_docker.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .stoplight_prism_docker.job_name | quote -]]
[[- end ]]
[[- end ]]

// Set the job name

[[ define "nomadvar_job_name" ]]
[[- if eq .stoplight_prism_docker.job_name "" -]]
[[- .nomad_pack.pack.name  -]]
[[- else -]]
[[- .stoplight_prism_docker.job_name  -]]
[[- end ]]
[[- end ]]

// only deploys to a region if specified

[[ define "region" -]]
[[- if not (eq .stoplight_prism_docker.region "") -]]
  region = [[ .stoplight_prism_docker.region | quote]]
[[- end -]]
[[- end -]]

// only deploys to a namespace if specified

[[ define "namespace" -]]
[[- if not (eq .stoplight_prism_docker.namespace "") -]]
  namespace = [[ .stoplight_prism_docker.namespace | quote]]
[[- end -]]
[[- end -]]