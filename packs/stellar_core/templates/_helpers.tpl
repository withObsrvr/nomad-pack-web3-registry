// Set the job name

[[ define "job_name" ]]
[[- if eq var "job_name"  "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- var "job_name"  | quote -]]
[[- end ]]
[[- end ]]

// Set the job name

[[ define "nomadvar_job_name" ]]
[[- if eq var "job_name"  "" -]]
[[- .nomad_pack.pack.name  -]]
[[- else -]]
[[- var "job_name"   -]]
[[- end ]]
[[- end ]]

// only deploys to a region if specified

[[ define "region" -]]
[[- if not (eq var "region"  "") -]]
  region = [[ var "region"  | quote]]
[[- end -]]
[[- end -]]

// only deploys to a namespace if specified

[[ define "namespace" -]]
[[- if not (eq var "namespace"  "") -]]
  namespace = [[ var "namespace"  | quote]]
[[- end -]]
[[- end -]]