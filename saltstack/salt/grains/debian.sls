# Debian default control

# Default sources
/etc/apt/sources.list:
  file.managed:
    - contents: |
        deb http://ftp.{{ pillar.network.cdn }}.debian.org/debian {{ grains.oscodename }} main contrib
        deb http://ftp.{{ pillar.network.cdn }}.debian.org/debian {{ grains.oscodename }}-updates main contrib
        deb http://security.debian.org {{ grains.oscodename }}-security main contrib
        {%- if pillar.apt.use_src %}
        deb-src http://ftp.{{ pillar.network.cdn }}.debian.org/debian {{ grains.oscodename }} main contrib
        deb-src http://ftp.{{ pillar.network.cdn }}.debian.org/debian {{ grains.oscodename }}-updates main contrib
        deb-src http://security.debian.org {{ grains.oscodename }}-security main contrib
        {%- endif %}
