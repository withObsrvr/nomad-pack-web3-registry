// Set the job name

[[ define "job_name" ]]
[[- if eq .stellar_quickstart.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .stellar_quickstart.job_name | quote -]]
[[- end ]]
[[- end ]]

// Set the job name

[[ define "nomadvar_job_name" ]]
[[- if eq .stellar_quickstart.job_name "" -]]
[[- .nomad_pack.pack.name  -]]
[[- else -]]
[[- .stellar_quickstart.job_name  -]]
[[- end ]]
[[- end ]]

// only deploys to a region if specified

[[ define "region" -]]
[[- if not (eq .stellar_quickstart.region "") -]]
  region = [[ .stellar_quickstart.region | quote]]
[[- end -]]
[[- end -]]

// only deploys to a namespace if specified

[[ define "namespace" -]]
[[- if not (eq .stellar_quickstart.namespace "") -]]
  namespace = [[ .stellar_quickstart.namespace | quote]]
[[- end -]]
[[- end -]]