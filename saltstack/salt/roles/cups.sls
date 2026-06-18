# This state manages CUPS printer config
{% set printers = salt['pillar.get']('cups:printers', {}) %}

cups_packages:
  pkg.installed:
    - pkgs:
      - cups
      - cups-filters        # driverless filters
      - cups-ipp-utils      # `driverless`/`ippfind` for discovery (optional)

cups_service:
  service.running:
    - name: cups
    - enable: true
    - require:
      - pkg: cups_packages

{% for name, cfg in printers.items() %}
cups_printer_{{ name }}:
  cmd.run:
    - name: >
        lpadmin -p {{ name }}
        -v '{{ cfg['uri'] }}'
        -m {{ cfg.get('model', 'everywhere') }}
        -D '{{ cfg.get('info', name) }}'
        -L '{{ cfg.get('location', '') }}'
        {%- for k, v in cfg.get('options', {}).items() %}
        -o {{ k }}={{ v }}
        {%- endfor %}
        -o printer-is-shared={{ cfg.get('shared', false) | string | lower }}
        -E
    - unless:
        - lpstat -v {{ name }} 2>/dev/null | grep -qF "{{ cfg['uri'] }}"
    - require:
      - service: cups_service
{% endfor %}

{% if salt['pillar.get']('cups:default') %}
cups_default_printer:
  cmd.run:
    - name: lpadmin -d {{ salt['pillar.get']('cups:default') }}
    - unless:
        - test "$(lpstat -d 2>/dev/null | awk '{print $NF}')" = "{{ salt['pillar.get']('cups:default') }}"
    - require:
      - service: cups_service
{% endif %}
