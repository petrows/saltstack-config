# Config for static local agent for VictoriaMetrics

vmagent:
  node_exporters:
    kg.sw.h.pws: {}
    kg.wlan.h.pws: {}
    sz.wlan.h.pws: {}
    ku.wlan.h.pws: {}
    vpn.b.pws:
      url: https://exporter.vpn.b.pws:4490/metrics
