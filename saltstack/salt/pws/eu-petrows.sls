# Config for Aruba VM

eu-soft:
  pkg.installed:
    - pkgs:
      - dirmngr

eu-java:
  pkgrepo.managed:
    - name: deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main
    - file: /etc/apt/sources.list.d/java.list
    - keyid: C2518248EEA14886
    - keyserver: keyserver.ubuntu.com
  pkg.installed:
    - pkgs:
      - openjdk-8-jre-headless
    - refresh: True
