{% from "ad/ds/map.jinja" import ad_ds_settings with context %}
{% from "ad/ds/options.jinja" import generate_promotion_command with context %}

include:
  - ad.ds.features
  - ad.ds.services

{% set operation = sls.split('.')[2] %}
{% call(command) generation_promotion_command(operation) %}
ad_ds_install:
  cmd.run:
    - shell: powershell
    - name: {{ command|yaml_encode }}
    - creates: {{ ad_ds_settings.DatabasePath|yaml_encode }}
    - require:
        - win_servermanager: ad_ds_features
    - watch_in:
        - service: ad_ds_services
{% endcall %}
