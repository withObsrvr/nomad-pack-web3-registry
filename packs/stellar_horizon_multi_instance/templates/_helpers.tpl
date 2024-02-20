// Set the job name

[[ define "job_name" ]]
[[- if eq .stellar_horizon_multi.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .stellar_horizon_multi.job_name | quote -]]
[[- end ]]
[[- end ]]

// Set the job name

[[ define "nomadvar_job_name" ]]
[[- if eq .stellar_horizon_multi.job_name "" -]]
[[- .nomad_pack.pack.name  -]]
[[- else -]]
[[- .stellar_horizon_multi.job_name  -]]
[[- end ]]
[[- end ]]

// only deploys to a region if specified

[[ define "region" -]]
[[- if not (eq .stellar_horizon_multi.region "") -]]
  region = [[ .stellar_horizon_multi.region | quote]]
[[- end -]]
[[- end -]]

// only deploys to a namespace if specified

[[ define "namespace" -]]
[[- if not (eq .stellar_horizon_multi.namespace "") -]]
  namespace = [[ .stellar_horizon_multi.namespace | quote]]
[[- end -]]
[[- end -]]