# Postgres Horizon

The Postgres Horizon nomad pack provides a docker instance of Postgresql for Stellar Horizon

## Variables

- `count` (number) - The number of app instances to deploy
- `job_name` (string) - The name to use as the job name which overrides using the pack name
- `datacenters` (list of strings) - A list of datacenters in the region which are eligible for task placement
- `image_args` (list of string) - The arguments to use for the Docker image
- `image_tag` (string) - The tag used for the Docker image
- `namespace` (string) - The Nomad namespace used for the job
- `region` (string) - The region where jobs will be deployed
- `register_service` (bool) - If you want to register a nomad service for the job
- `registered_service_name` (string) - The service name used in Service Discovery
- `service_registration_provider` (string) - The provider name used for Service Discovery
- `service_tags` (list of string) - List of tags associated with the Service
- `task_resources` (object) - An object of the resources allocated to the task
`history_archive_urls` (string) - A string of the URLS for the history archives
