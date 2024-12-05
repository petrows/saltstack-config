# k8s node as CT

# Startup CT fix
/etc/rc.local:
  file.managed:
    - contents: |
        #!/bin/sh -e
        # Kubeadm 1.15 needs /dev/kmsg to be there, but it’s not in lxc, but we can just use /dev/console instead
        # see: https://github.com/kubernetes-sigs/kind/issues/662if [ ! -e /dev/kmsg ]; then
        ln -s /dev/console /dev/kmsg
        fi# https://medium.com/@kvaps/run-kubernetes-in-lxc-container-f04aa94b6c9c
        mount --make-rshared /
