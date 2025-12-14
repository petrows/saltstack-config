# Role for Github runner

# Software prerequisites

/etc/apt/sources.list.d/github.sources:
  file.managed:
    - contents: |
        X-Repolib-Name: Github CLI
        Description: GitHub CLI is a command line tool that brings pull requests, issues, and other GitHub concepts to the terminal next to where you are already working.
          - Website: https://cli.github.com/
          - Public key: https://cli.github.com/packages/githubcli-archive-keyring.gpg
        Enabled: yes
        Types: deb
        URIs: https://cli.github.com/packages
        Signed-By: /etc/apt/keyrings/githubcli.gpg
        Suites: stable
        Components: main

github-cli-pkg:
  pkg.installed:
    - pkgs:
      - gh

# Common github runner tmp
/home/github/tmp:
  file.directory:
    - user: github
    - group: github

# Iterate runners

{% for id, runner in salt['pillar.get']('pws_secrets:github_runners:runners', {}).items() %}

github-{{ id }}-tmp:
  file.directory:
    - name: /home/github/{{ id }}/tmp
    - user: github
    - group: github

github-{{ id }}-package:
  archive.extracted:
    - name: /home/github/{{ id }}/
    - user: github
    - group: github
    - source: {{ pillar.github_runner.package.url }}
    - source_hash: {{ pillar.github_runner.package.hash }}

github-{{ id }}-configure:
  file.managed:
    - name: /home/github/{{ id }}/pws-runner-configure
    - contents: |
        #!/bin/sh -xe
        if [[ -z "$GH_TOKEN" ]]; then
          echo "GH_TOKEN is not set"
          exit 1
        fi
        # Get new runner token for provisioning
        RUNNER_TOKEN=$(curl -sX POST -H "Accept: application/vnd.github+json" \
          -H "Authorization: Bearer $GH_TOKEN" \
          https://api.github.com/repos/{{ runner.owner }}/{{ runner.repo }}/actions/runners/registration-token \
          | jq -r .token )
        # Start new instance
        ./config.sh remove --local || true
        ./config.sh \
          --unattended \
          --url https://github.com/{{ runner.owner }}/{{ runner.repo }} \
          --token "$RUNNER_TOKEN" \
          --name {{ grains.id }} \
          --replace
    - mode: 755
    - user: github
    - group: github

github-{{ id }}-configure-update:
  cmd.run:
    - name: ./pws-runner-configure
    - cwd: /home/github/{{ id }}/
    - env:
      - GH_TOKEN: "{{ pillar.pws_secrets.github_runners.administration_rw_token }}"
    - runas: github
    - onchanges:
      - file: github-{{ id }}-configure

github-runner-{{ id }}.service:
  file.managed:
    - name: /etc/systemd/system/github-runner-{{ id }}.service
    - contents: |
        [Unit]
        Description=Github runner: {{ id }}
        After=network.target
        OnFailure=status-email@%n.service
        [Service]
        Type=simple
        User=github
        Group=github
        WorkingDirectory=/home/github/{{ id }}/
        ExecStart=/home/github/{{ id }}/run.sh
        [Install]
        WantedBy=multi-user.target
  service.running:
    - enable: True
    - no_block: True
    - watch:
      - file: /etc/systemd/system/github-runner-{{ id }}.service
      - cmd: github-{{ id }}-configure-update

{% endfor %}
