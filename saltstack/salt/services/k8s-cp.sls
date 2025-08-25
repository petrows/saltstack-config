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

{% set kube_open_ports = ['10257', '10259'] %}

# -A PREROUTING ! -d 127.0.0.1/32 -p tcp -m tcp --dport 10259 -j DNAT --to-destination 127.0.0.1:10259
# -A PREROUTING ! -d 127.0.0.1/32 -p tcp -m tcp --dport 10257 -j DNAT --to-destination 127.0.0.1:10257

{% for port in kube_open_ports %}
# Redirect localhost-only ports from external requests
kube-port-{{ port }}:
  iptables.insert:
    - position: 1
    - table: nat
    - chain: PREROUTING
    - jump: DNAT
    - destination: '! 127.0.0.1'
    - dport: '{{ port }}'
    - protocol: tcp
    - to-destination: '127.0.0.1:{{ port }}'
    - save: True
{% endfor %}
