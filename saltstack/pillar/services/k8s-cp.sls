# Root CP for k8s configuration

{% import_yaml 'static.yaml' as static %}

# No swap allowed
swap_size_mb: 0

roles:
  - nftables
  - k8s-cp

k8s:
  init:
    # We should use ip-address here, for nodes, where internal DNS
    # is not avalaible
    controlPlaneEndpoint: "k8s-cp-h1.pws:6443"
    networking:
      serviceSubnet: "10.98.0.0/16"
      podSubnet: "10.99.0.0/16"

# Firewall rules for NAT
{% set kube_open_ports = ['10257', '10259'] %}
firewall:
  rules_nat_prerouting_v4:
    {% for port in kube_open_ports %}
    kube_cp_port_{{ port }}: "ip daddr != 127.0.0.1 tcp dport {{ port }} counter dnat to 127.0.0.1:{{ port }}"
    {% endfor %}

# User env to allow use kubectl
shell_env:
  KUBECONFIG: "/etc/kubernetes/admin.conf"
