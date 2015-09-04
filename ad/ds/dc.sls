{% from "ad/ds/map.jinja" import ad_ds_settings with context %}

include:
  - ad.ds.install
  - ad.ds.services

ad_ds_replica_dc:
  win_servermanager.installed:
    - names: {{ ad_ds_settings.features|yaml }}
  cmd.run:
    - shell: powershell
    - name: 'Import-Module ADDSDeployment; $Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList {{ ad_ds_settings.credentials.username }}, (ConvertTo-SecureString -String "{{ ad_ds_settings.credentials.password }}" -AsPlainText -Force); Install-ADDSDomainController -ADPrepCredential $Credentials -ApplicationPartitionsToReplicate "*" -CreateDnsDelegation:$true -Credential $Credentials -DnsDelegationCredential $Credentials -DomainName "{{ ad_ds_settings.domain }}" -InstallDns:$true -LogPath "{{ ad_ds_settings.log }}" -SafeModeAdministratorPassword (ConvertTo-SecureString -String "{{ ad_ds_settings.rm_password }}" -AsPlainText -Force) -SysvolPath "{{ ad_ds_settings.sysvol }}" -NoRebootOnCompletion:$true -Force:$true'
    - creates: '{{ ad_ds_settings.database }}'
    - require:
        - win_servermanager: ad_ds_features
    - watch_in:
        - service: ad_ds_services
