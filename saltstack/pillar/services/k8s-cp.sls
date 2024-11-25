# Root CP for k8s configuration

{% import_yaml 'static.yaml' as static %}

roles:
  - k8s-cp

k8s:
  init:
    controlPlaneEndpoint: "k8s-cp.pws:6443"
    networking:
      podSubnet: 10.99.0.0/16
