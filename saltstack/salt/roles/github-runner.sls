# Role for Github runner


# Iterate runners

{% for id, runner in salt['pillar.get']('pws_secrets:github_runners:runners', {}).items() %}

github-{{ id }}-package:
  archive.extracted:
    - name: /home/github/{{ id }}/
    - user: github
    - group: github
    - source: {{ pillar.github_runner.package.url }}
    - source_hash: {{ pillar.github_runner.package.hash }}

github-{{ id }}-script:
  file.managed:
    - name: /home/github/{{ id }}/pws-runner
    - contents: |
        #!/bin/sh -xe
        ./config.sh remove --local || true
        ./config.sh \
          --unattended \
          --url {{ runner.url }} \
          --token {{ runner.token }} \
          --name {{ grains.id }} \
          --replace
        ./run.sh
    - mode: 755
    - user: github
    - group: github

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
        ExecStart=/home/github/{{ id }}/pws-runner
        [Install]
        WantedBy=multi-user.target
  service.running:
    - enable: True
    - no_block: True
    - watch:
      - file: /etc/systemd/system/github-runner-{{ id }}.service
      - file: /home/github/{{ id }}/pws-runner

{% endfor %}
