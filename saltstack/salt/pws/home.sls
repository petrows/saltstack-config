# Smart-home root server has it's own config

openhab-repository:
  pkgrepo.managed:
    - name: deb https://dl.bintray.com/openhab/apt-repo2 stable main
    - file: /etc/apt/sources.list.d/openhab.list
    - keyid: EDB7D0304E2FCAF629DF1163075721F6A224060A
    - keyserver: https://bintray.com/user/downloadSubjectPublicKey?username=openhab

openhab-package:
  pkg.installed:
    - install_recommends: True
    - pkgs:
      - openhab2: {{ pillar.openhab.version }}
      - mosquitto
      - openjdk-11-jre-headless

openhab2.service:
  service.running:
    - enable: True
