{% from "ad/ds/map.jinja" import ad_ds_settings with context %}

ad_ds_services:
  service.running:
    - names: {{ ad_ds_settings.services|yaml }}
    - enable: True
