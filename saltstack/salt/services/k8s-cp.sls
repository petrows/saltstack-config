# The K8S cluster cp role

{%- set default_interface = (salt['network.default_route']('inet')|first)['interface']|default('none') %}
{%- if default_interface %}
    {%- set default_addr = (salt['network.interface_ip'](default_interface)) %}
{%- endif %}

/etc/kubernetes/init/kubeadm.yaml:
  file.managed:
    - makedirs: True
    - mode: 600
    - contents: |
        apiVersion: kubeadm.k8s.io/v1beta4
        kind: InitConfiguration
        localAPIEndpoint:
          advertiseAddress: {{ default_addr }}
          bindPort: 6443
        ---
        apiVersion: kubeadm.k8s.io/v1beta4
        kind: ClusterConfiguration
        kubernetesVersion: {{ pillar.k8s.version }}.0
        controlPlaneEndpoint: "{{ pillar.k8s.init.controlPlaneEndpoint}}"
        networking:
          serviceSubnet: {{ pillar.k8s.init.networking.serviceSubnet}}
          podSubnet: {{ pillar.k8s.init.networking.podSubnet}}

/usr/local/sbin/k8s-backup-etcd:
  file.managed:
    - mode: 755
    - contents: |
        #!/bin/bash -xe

        # Allow to use system kubectl
        export KUBECONFIG="/etc/kubernetes/admin.conf"

        # Settings
        NAMESPACE="kube-system"
        ETCD_POD=$(kubectl -n ${NAMESPACE} get pods -l component=etcd -o jsonpath='{.items[0].metadata.name}')
        BACKUP_DIR="/srv/backup/etcd"
        MAX_BACKUPS=7

        # Create backup folder
        mkdir -p "${BACKUP_DIR}"
        # Filname with timestamp
        SNAPSHOT_FILE="etcd-snapshot-$(date +%Y-%m-%d_%H-%M-%S).db"
        LOCAL_PATH="${BACKUP_DIR}/${SNAPSHOT_FILE}"
        POD_PATH="/var/lib/etcd/${SNAPSHOT_FILE}"

        echo "[INFO] Using etcd pod: ${ETCD_POD}"
        echo "[INFO] Creating snapshot inside pod..."

        kubectl -n ${NAMESPACE} exec "${ETCD_POD}" -- \
          etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt \
                  --cert=/etc/kubernetes/pki/etcd/server.crt \
                  --key=/etc/kubernetes/pki/etcd/server.key \
                  snapshot save "${POD_PATH}"

        # Move done inside pod to backup folder mounted on host
        mv "${POD_PATH}" "${LOCAL_PATH}"

        # Cleanup old backups
        BACKUP_COUNT=$(ls -1 "${BACKUP_DIR}"/*.db | wc -l)
        if [ "${BACKUP_COUNT}" -gt "${MAX_BACKUPS}" ]; then
          echo "[INFO] Cleaning up old snapshots..."
          ls -1t "${BACKUP_DIR}"/*.db | tail -n +$((MAX_BACKUPS+1)) | xargs rm -f
        fi

        echo "[INFO] Done. Snapshot saved to ${LOCAL_PATH}"

k8s-backup.service:
  file.managed:
    - name: /etc/systemd/system/k8s-backup.service
    - contents: |
        [Unit]
        Description=k8s backup
        OnFailure=status-email@%n.service
        [Service]
        Type=oneshot
        RemainAfterExit=no
        User=root
        Group=root
        WorkingDirectory=/
        ExecStart=/usr/local/sbin/k8s-backup-etcd
  service.disabled: []

k8s-backup.timer:
  file.managed:
    - name: /etc/systemd/system/k8s-backup.timer
    - contents: |
        [Unit]
        Description=k8s backup timer
        [Timer]
        OnCalendar=*-*-* 6:00:00
        Unit=k8s-backup.service
        [Install]
        WantedBy=timers.target
  service.running:
    - enable: True

# Startup k8s cp configs

k8s-node-startup.service:
  file.managed:
    - name: /etc/systemd/system/k8s-node-startup.service
    - contents: |
        [Unit]
        Description=K8s Node Startup Service
        After=network.target
        [Service]
        Type=oneshot
        RemainAfterExit=yes
        ExecStart=/usr/local/bin/k8s-node-startup
        [Install]
        WantedBy=multi-user.target
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/k8s-node-startup.service
      - file: /usr/local/bin/k8s-node-startup

/usr/local/bin/k8s-node-startup:
  file.managed:
    - mode: 755
    - contents: |
        #!/bin/bash -e
        iptables -t nat -A PREROUTING ! -d 127.0.0.1/32 -p tcp -m tcp --dport 10259 -j DNAT --to-destination 127.0.0.1:10259
        iptables -t nat -A PREROUTING ! -d 127.0.0.1/32 -p tcp -m tcp --dport 10257 -j DNAT --to-destination 127.0.0.1:10257
        echo "K8s cp startup script executed"
