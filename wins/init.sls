{% from "wins/map.jinja" import wins_settings with context %}

wins:
  win_servermanager.installed:
    - names: {{ wins_settings.features|yaml }}
  service.running:
    - names: {{ wins_settings.services|yaml }}
    - enable: True
    - watch:
        - win_servermanager: wins
  cmd.script:
    - shell: cmd
    - source: salt://wins/files/wins-server-setup.bat
    - template: jinja
    - require:
        - service: wins
