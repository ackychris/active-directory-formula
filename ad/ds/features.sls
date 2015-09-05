{% from "ad/ds/map.jinja" import ad_ds_settings with context %}

ad_ds_features:
  win_servermanager.installed:
    - names: {{ ad_ds_settings.features|yaml }}
