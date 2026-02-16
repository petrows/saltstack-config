{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('whatsapp-proxy') }}
