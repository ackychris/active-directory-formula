{% from "ad/ds/map.jinja" import ad_ds_settings, ad_ds_knobs with context %}

{% macro process_options(operation) %}
  {% set retval = [] %}
  {% for variable, type in ad_ds_knobs[operation].items() %}
    {% if variable in ad_ds_settings %}
      {% set value = ad_ds_settings[variable] %}
      {% if type == 'boolean' %}
        {% do retval.append('-%s:$%s'|format(variable, value)) %}
      {% elif type == 'literal' %}
        {% if value is sequence and value is not string %}
          {% do retval.append('-%s %s'|format(variable, value|join(' '))) %}
        {% else %}
          {% do retval.append('-%s %s'|format(variable, value)) %}
        {% endif %}
      {% elif type == 'secure-string' %}
        {% do retval.append('-%s (ConvertTo-SecureString -String "%s" -AsPlainText -Force)'|format(variable, value)) %}
      {% elif type == 'pscredential' %}
        {% do retval.append('-%s (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "%s", (ConvertTo-SecureString -String "%s" -AsPlainText -Force))'|format(variable, value.username, value.password)) %}
      {% endif %}
    {% endif %}
  {% endfor %}
  {% do caller(retval) %}
{% endmacro %}

{% set command = [ 'Import-Module ADDSDeployment;' ] %}
{% set operation = sls.split('.')[2] %}
{% if operation == 'forest' %}
  {% do command.append('Install-ADDSForest') %}
{% elif operation == 'domain ' %}
  {% do command.append('Install-ADDSDomain') %}
{% elif operation in [ 'dc', 'rodc' ] %}
  {% if operation == 'rodc' %}
    {% do command.append('Add-ADDSReadOnlyDomainControllerAccount') %}
    {% call(options) process_options('rodc') %}
      {% do command.extend(options) %}
    {% endcall %}
    {% do command.append(';') %}
  {% endif %}
  {% do command.append('Install-ADDSDomainController') %}
{% endif %}
{% call(options) process_options(operation) %}
  {% do command.extend(options) %}
{% endcall %}
{% call(options) process_options('common') %}
  {% do command.extend(options) %}
{% endcall %}
{% do command.append('-Force:$true -NoRebootOnCompletion:$true') %}

include:
  - ad.ds.features
  - ad.ds.services

ad_ds_install:
  cmd.run:
    - shell: powershell
    - name: {{ command|join(" ")|yaml_encode }}
    - creates: {{ ad_ds_settings.DatabasePath|yaml_encode }}
    - require:
        - win_servermanager: ad_ds_features
    - watch_in:
        - service: ad_ds_services
