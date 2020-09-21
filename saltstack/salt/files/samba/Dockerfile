FROM {{ pillar.samba.version_base }}

RUN apk add --update \
    samba-common-tools \
    samba-client \
    samba-server \
    && rm -rf /var/cache/apk/*

VOLUME ["/etc/samba", "/var/lib/samba", "/var/log/samba", "/var/cache/samba" ]

ENTRYPOINT ["smbd", "--foreground", "--log-stdout", "--no-process-group"]
CMD []
