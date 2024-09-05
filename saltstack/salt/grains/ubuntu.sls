# Ubuntu system
{% set deb_source_type = 'deb' %}
{% if pillar.apt.use_src %}
{% set deb_source_type = 'deb deb-src' %}
{% endif %}

# Default sources
/etc/apt/sources.list.d/ubuntu.sources:
  file.managed:
    - contents: |
        Types: {{ deb_source_type }}
        URIs: http://{{ pillar.network.cdn }}.archive.ubuntu.com/ubuntu
        Suites: {{ grains.oscodename }} {{ grains.oscodename }}-updates {{ grains.oscodename }}-backports
        Components: main restricted universe multiverse
        Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

        Types: {{ deb_source_type }}
        URIs: http://security.ubuntu.com/ubuntu
        Suites: {{ grains.oscodename }}-security
        Components: main restricted universe multiverse
        Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
