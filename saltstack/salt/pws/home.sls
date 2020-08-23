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
      - openhab2
      - mosquitto
      - openjdk-11-jre-headless

openhab2.service:
  service.running:
    - enable: True

grafana-repository:
  pkgrepo.managed:
    - name: deb https://packages.grafana.com/oss/deb stable main
    - file: /etc/apt/sources.list.d/grafana.list
    - keyid: 4E40DDF6D76E284A4A6780E48C8C34C524098CB6
    - keyserver: https://packages.grafana.com/gpg.key

grafana-package:
  pkg.installed:
    - install_recommends: True
    - pkgs:
      - grafana

grafana-server.service:
  service.running:
    - enable: True
