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
    controlPlaneEndpoint: "10.80.0.7:6443"
    networking:
      podSubnet: 10.99.0.0/16
