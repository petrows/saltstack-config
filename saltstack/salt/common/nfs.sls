# Common Salt for NFS exports manage

nfs-packages:
  pkg.installed:
    - pkgs:
      - nfs-kernel-server

/etc/default/nfs-kernel-server:
  file.managed:
    - contents: |
        # Number of servers to start up
        RPCNFSDCOUNT=8

        # Runtime priority of server (see nice(1))
        RPCNFSDPRIORITY=0

        # Options for rpc.mountd.
        # If you have a port-based firewall, you might want to set up
        # a fixed port here using the --port option. For more information,
        # see rpc.mountd(8) or http://wiki.debian.org/SecuringNFS
        # To disable NFSv4 on the server, specify '--no-nfs-version 4' here
        RPCMOUNTDOPTS="--manage-gids -p {{ salt['pillar.get']('nfs:ports:mountd') }}"

        # Do you want to start the svcgssd daemon? It is only required for Kerberos
        # exports. Valid alternatives are "yes" and "no"; the default is "no".
        NEED_SVCGSSD=""

        # Options for rpc.svcgssd.
        RPCSVCGSSDOPTS=""

/etc/default/nfs-common:
  file.managed:
    - contents: |
        # If you do not set values for the NEED_ options, they will be attempted
        # autodetected; this should be sufficient for most people. Valid alternatives
        # for the NEED_ options are "yes" and "no".

        # Do you want to start the statd daemon? It is not needed for NFSv4.
        NEED_STATD=

        # Options for rpc.statd.
        #   Should rpc.statd listen on a specific port? This is especially useful
        #   when you have a port-based firewall. To use a fixed port, set this
        #   this variable to a statd argument like: "--port 4000 --outgoing-port 4001".
        #   For more information, see rpc.statd(8) or http://wiki.debian.org/SecuringNFS
        STATDOPTS="--port {{ salt['pillar.get']('nfs:ports:statd') }} --outgoing-port {{ salt['pillar.get']('nfs:ports:statd') + 1 }}"

        # Do you want to start the idmapd daemon? It is only needed for NFSv4.
        NEED_IDMAPD=

        # Do you want to start the gssd daemon? It is required for Kerberos mounts.
        NEED_GSSD=

fs.nfs.nlm_tcpport:
  sysctl.present:
    - value: {{ salt['pillar.get']('nfs:ports:lockd') }}

fs.nfs.nlm_udpport:
  sysctl.present:
    - value: {{ salt['pillar.get']('nfs:ports:nlm') }}

{% for id, export in salt['pillar.get']('nfs-exports', {}).items() %}
{{ export.path }}:
  file.directory:
    - user: {{ export.user }}
    - group: {{ export.get('group', export.user) }}
    - mode: {{ export.mode }}
    - makedirs: True

nfs-export-{{ id }}:
  nfs_export.present:
    - name: {{ export.path }}
    - clients:
    {% for host in export.hosts %}
      - hosts: {{ host.host }}
        options:
      {% for opt in host.opts %}
        - {{ opt }}
      {% endfor %}
    {% endfor %}
    - require:
      - pkg: nfs-packages
      - file: {{ export.path }}
{% endfor %}
