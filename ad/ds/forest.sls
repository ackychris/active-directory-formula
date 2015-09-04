{% from "ad/ds/map.jinja" import ad_ds_settings with context %}

ad_ds_forest_root_dc:
  win_servermanager.installed:
    - names: {{ ad_ds_settings.features|yaml }}
  cmd.run:
    - shell: powershell
    - name: 'Import-Module ADDSDeployment; Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "{{ ad_ds_settings.database }}" -DomainMode "{{ ad_ds_settings.domain_mode }}" -DomainName "{{ ad_ds_settings.domain }}" -DomainNetbiosName "{{ ad_ds_settings.netbios }}" -DomainMode "{{ ad_ds_settings.domain_mode }}" -ForestMode "{{ ad_ds_settings.forest_mode }}" -InstallDns:$true -LogPath "{{ ad_ds_settings.log }}" -SafeModeAdministratorPassword (ConvertTo-SecureString -String "{{ ad_ds_settings.rm_password }}" -AsPlainText -Force) -SysvolPath "{{ ad_ds_settings.sysvol }}" -NoRebootOnCompletion:$true -Force:$true'
    - creates: '{{ ad_ds_settings.database }}'
    - require:
        - win_servermanager: ad_ds_forest_root_dc
