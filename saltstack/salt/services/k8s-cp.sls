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
        nodeRegistration:
          kubeletExtraArgs:
            node-ip: {{ default_addr }}
        ---
        apiVersion: kubeadm.k8s.io/v1beta4
        kind: ClusterConfiguration
        kubernetesVersion: 1.28.8
        controlPlaneEndpoint: "{{ pillar.k8s.init.controlPlaneEndpoint}}"
        networking:
          podSubnet: {{ pillar.k8s.init.networking.podSubnet}}
