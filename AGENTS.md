# Project

Infra configuration project, uses Saltstack 3007.3.

## Pillar location

Defaults: `saltstack/pillar/default.sls`
Secrets defaults (stub): `saltstack/pillar/secrets-default.sls`

All secrets should have empty/default value in stub file. Prodcution is located under `/secrets` and reading any files there is restricted.

## Salt states

File states must have filename as ID to avoid duplications.

## Systemd services configuration

Simple systemd-timer script call ca be defined via `pillar.systemd-cron`.

Complex scripts / services, called via systemd:

* Codebase: see "Codebase" section
* Should use systemd-notify API to report running state
* Service should have pair of files:
    * `service-name.service` - main unit
    * `service-name.timer` - timer unit (if service called periodically)
    * All files must be defined inline in State
    * Service must have `OnFailure=status-email@%n.service` to report failure
* Service must have retry option for all networking operations
* All services have persistance in `/srv/service-name`

## Docker-based service configuration

Service, running as docker image.

Service with WEB-UI must have working port reserved in `saltstack/pillar/static.yaml`.

Pillar definition, `pillar/services/service-name.sls`. Do not use -dev, -prod tree.
Pillar must define role name, base options for service, and vhost (if web-based):

```yaml
roles:
  - service-name

service-name:
  # https://github.com/DNSCrypt/dnscrypt-proxy/releases (link to docker tags / releases)
  version: 2.1.7 # Current version
  config:
    listen_port: 1234

proxy_vhosts:
  service-name:
    domain: service.local.pws
    port: {{ static.proxy_ports.service_name_http }}
    ssl: internal
    ssl_name: local
```

Domain name must be local.pws as default with local SSL (ssl_name: local). Agent should not define
production values.

Files definition:

Service must have file structure:

* `saltstack/salt/files/service-name/compose/docker-compose.yml` - compose file with jinja template.
* `saltstack/salt/files/service-name/<files>` - files, to be mounted (scripts, config).

Compose file must use key-value object definition, avoid usage of lists.

States definition:

* Working directory for compose service: `/opt/service-name`
* Working directory for persistance: `/srv/service-name`
* Subfolders for database, app, etc, with proper owner UID
* Working files, i.e. configs. Files must be mounted as R/O where possible

Files, which require service restart, must have:

```yaml
- watch_in:
  - service: service-name.service
```

Compose service must be defined as macro:

```yaml
{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('service-name') }}
```

## Codebase

Scripts must be written on modern python, complain to PEP.
Scripts must pass pylint.

Scripts must use `argparse`
Config files must be in `yaml` format
Formatting: see `.editorconfig`

Global packages installed: `saltstack/salt/common/packages.sls`

Scripts, which require custom module installation, must:

* Use system venv managed: `/opt/venv/app`, defined in `saltstack/salt/common/python.sls`
* If not possible, service must have local `venv` managed folder inside `/opt/service-name/venv`

## Configuration apply

All hosts locally: `./bin/apply-ssh web-vm.pws state.apply`
