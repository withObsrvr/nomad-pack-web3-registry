// Set the job name

[[ define "job_name" ]]
[[- if eq .stellar_core.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .stellar_core.job_name | quote -]]
[[- end ]]
[[- end ]]

// Set the job name

[[ define "nomadvar_job_name" ]]
[[- if eq .stellar_core.job_name "" -]]
[[- .nomad_pack.pack.name  -]]
[[- else -]]
[[- .stellar_core.job_name  -]]
[[- end ]]
[[- end ]]

// only deploys to a region if specified

[[ define "region" -]]
[[- if not (eq .stellar_core.region "") -]]
  region = [[ .stellar_core.region | quote]]
[[- end -]]
[[- end -]]

// only deploys to a namespace if specified

[[ define "namespace" -]]
[[- if not (eq .stellar_core.namespace "") -]]
  namespace = [[ .stellar_core.namespace | quote]]
[[- end -]]
[[- end -]]