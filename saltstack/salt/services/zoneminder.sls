# https://github.com/ZoneMinder/zoneminder
#

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('zoneminder') }}
