// Set the job name

[[ define "job_name" ]]
[[- if eq .opensearch.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .opensearch.job_name | quote -]]
[[- end ]]
[[- end ]]

// Set the job name

[[ define "nomadvar_job_name" ]]
[[- if eq .opensearch.job_name "" -]]
[[- .nomad_pack.pack.name  -]]
[[- else -]]
[[- .opensearch.job_name  -]]
[[- end ]]
[[- end ]]

// only deploys to a region if specified

[[ define "region" -]]
[[- if not (eq .opensearch.region "") -]]
  region = [[ .opensearch.region | quote]]
[[- end -]]
[[- end -]]

// only deploys to a namespace if specified

[[ define "namespace" -]]
[[- if not (eq .opensearch.namespace "") -]]
  namespace = [[ .opensearch.namespace | quote]]
[[- end -]]
[[- end -]]