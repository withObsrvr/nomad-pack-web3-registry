// Set the job name

[[ define "job_name" ]]
[[- if eq .postgres_horizon.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .postgres_horizon.job_name | quote -]]
[[- end ]]
[[- end ]]

// Set the job name

[[ define "nomadvar_job_name" ]]
[[- if eq .postgres_horizon.job_name "" -]]
[[- .nomad_pack.pack.name  -]]
[[- else -]]
[[- .postgres_horizon.job_name  -]]
[[- end ]]
[[- end ]]

// only deploys to a region if specified

[[ define "region" -]]
[[- if not (eq .postgres_horizon.region "") -]]
  region = [[ .postgres_horizon.region | quote]]
[[- end -]]
[[- end -]]

// only deploys to a namespace if specified

[[ define "namespace" -]]
[[- if not (eq .postgres_horizon.namespace "") -]]
  namespace = [[ .postgres_horizon.namespace | quote]]
[[- end -]]
[[- end -]]