{% from "ad/ds/map.jinja" import ad_ds_settings with context %}

ad_ds_services:
  service.running:
{% if salt['file.directory_exists'](ad_ds_settings.DatabasePath) %}
    - names: {{ ad_ds_settings.services|yaml }}
{% else %}
    ## safe if AD DS isn't installed yet
    - name: eventlog
{% endif %}
    - enable: True
