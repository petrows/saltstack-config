# Config for Aruba VM

# Does not work...
# Can be fixed with
# deb http://archive.debian.org/debian/ jessie-backports main contrib non-free
# deb-src http://archive.debian.org/debian/ jessie-backports main contrib non-free
# echo 'Acquire::Check-Valid-Until no;' > /etc/apt/apt.conf.d/99no-check-valid-until
# apt install ca-certificates-java=20161107~bpo8+1
# openjdk-8-jre-headless

# eu-soft:
#   pkg.installed:
#     - pkgs:
#       - dirmngr

# eu-java:
#   pkgrepo.managed:
#     - name: deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main
#     - file: /etc/apt/sources.list.d/java.list
#     - keyid: C2518248EEA14886
#     - keyserver: keyserver.ubuntu.com
#   pkg.installed:
#     - pkgs:
#       - openjdk-8-jre-headless
#     - refresh: True
