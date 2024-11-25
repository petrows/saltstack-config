# Root CP for k8s configuration

{% import_yaml 'static.yaml' as static %}

# No swap allowed
swap_size_mb: 0

roles:
  - k8s-cp

k8s:
  init:
    # We should use ip-address here, for nodes, where internal DNS
    # is not avalaible
    controlPlaneEndpoint: "k8s-cp.pws:6443"
    networking:
      serviceSubnet: "10.98.0.0/16"
      podSubnet: "10.99.0.0/16"
