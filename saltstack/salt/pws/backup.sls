backup_packages:
  pkg.installed:
    - pkgs:
      - openjdk-11-jre
      - libxss1

cmd-test:
  cmd.run:
    - name: |
        cd ~
        wget https://download.code42.com/installs/agent/7.4.0/566/install/CrashPlanSmb_7.4.0_1525200006740_566_Linux.tgz
        tar -xf CrashPlanSmb_7.4.0_1525200006740_566_Linux.tgz
        ./crashplan-install/install.sh -q
        rm -rf CrashPlanSmb* crashplan-install
    - creates: /usr/local/crashplan
