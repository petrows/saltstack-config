# Ubuntu system
{% set deb_source_type = 'deb' %}
{% if pillar.apt.use_src %}
{% set deb_source_type = 'deb deb-src' %}
{% endif %}

# Default sources
/etc/apt/sources.list:
  file.managed:
    - contents: |
        {{ deb_source_type }} http://ftp.{{ pillar.network.cdn }}.debian.org/debian {{ grains.oscodename }} main contrib
        {{ deb_source_type }} http://ftp.{{ pillar.network.cdn }}.debian.org/debian {{ grains.oscodename }}-updates main contrib
        {{ deb_source_type }} http://security.debian.org {{ grains.oscodename }}-security main contrib
