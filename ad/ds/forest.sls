{% from "ad/ds/map.jinja" import ad_ds_settings with context %}

ad_ds_forest_root_dc:
  win_servermanager.installed:
    - names: {{ ad_ds_settings.features|yaml }}
  cmd.run:
    - shell: powershell
    - name: 'Import-Module ADDSDeployment; Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "{{ ad_ds_settings.path.database }}" -DomainMode "{{ ad_ds_settings.mode.domain }}" -DomainName "{{ ad_ds_settings.domain }}" -DomainNetbiosName "{{ ad_ds_settings.netbios }}" -DomainMode "{{ ad_ds_settings.mode.domain }}" -ForestMode "{{ ad_ds_settings.mode.forest }}" -InstallDns:$true -LogPath "{{ ad_ds_settings.path.log }}" -SafeModeAdministratorPassword (ConvertTo-SecureString -String "{{ ad_ds_settings.rm.password }}" -AsPlainText -Force) -SysvolPath "{{ ad_ds_settings.path.sysvol }}" -NoRebootOnCompletion:$true -Force:$true'
    - creates: '{{ ad_ds_settings.path.database }}'
    - require:
        - win_servermanager: ad_ds_forest_root_dc
