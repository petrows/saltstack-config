# Ubuntu system
{% set deb_source_type = 'deb' %}
{% if pillar.apt.use_src %}
{% set deb_source_type = 'deb deb-src' %}
{% endif %}
{% set deb_source_url_normal = salt['pillar.get']('apt:url_normal', 'http://'+pillar.network.cdn+'.archive.ubuntu.com/ubuntu') %}
{% set deb_source_url_security = salt['pillar.get']('apt:url_security', 'http://security.ubuntu.com/ubuntu') %}

# Default sources
/etc/apt/sources.list.d/ubuntu.sources:
  file.managed:
    - contents: |
        Types: {{ deb_source_type }}
        URIs: {{ deb_source_url_normal }}
        Suites: {{ grains.oscodename }} {{ grains.oscodename }}-updates {{ grains.oscodename }}-backports
        Components: main restricted universe multiverse
        Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

        Types: {{ deb_source_type }}
        URIs: {{ deb_source_url_security }}
        Suites: {{ grains.oscodename }}-security
        Components: main restricted universe multiverse
        Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
