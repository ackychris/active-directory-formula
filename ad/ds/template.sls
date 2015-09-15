{% from "ad/ds/map.jinja" import ad_ds_settings with context %}
{% from "ad/ds/options.jinja" import generate_promotion_command with context %}

{% set operation = sls.split('.')[2] %}
{% call(shell, command) generate_promotion_command(operation) %}
ad_ds:
  pkg.installed:
    - pkgs: {{ ad_ds_settings.packages|yaml }}
  win_servermanager.installed:
    - names: {{ ad_ds_settings.features|yaml }}
    - require:
        - pkg: ad_ds
  cmd.run:
    {% if shell %}
    - shell: {{ shell|yaml_encode }}
    {% endif %}
    - name: {{ command|yaml_encode }}
    - creates: {{ ad_ds_settings.DatabasePath|yaml_encode }}
    - require:
        - win_servermanager: ad_ds
  service.running:
    {% if salt['file.directory_exists'](ad_ds_settings.DatabasePath) %}
    - names: {{ ad_ds_settings.services|yaml }}
    {% else %}
    - name: eventlog            # safe no-op
    {% endif %}
    - enable: True
    - require:
        - cmd: ad_ds
{% endcall %}
