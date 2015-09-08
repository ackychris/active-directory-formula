{%- from "wins/map.jinja" import wins_settings with context -%}
{%- set servername = salt['grains.get']('host') -%}
@ECHO OFF

REM Configure WINS backups, database consistency checking, and
REM replication defaults.
netsh wins server \\{{ servername }} set backuppath dir=C:\Windows\System32\wins.bak shutdown=1
netsh wins server \\{{ servername }} set namerecord renew=2400 extinction=2400 extimeout=86400 verification=2073600
netsh wins server \\{{ servername }} set periodicdbchecking state=1 maxrec=30000 checkagainst=0 checkevery=24 start=7200
netsh wins server \\{{ servername }} set replicateflag state=1
netsh wins server \\{{ servername }} set migrateflag state=0
netsh wins server \\{{ servername }} set pullparam state=1 strtup=1 start=0 interval=1800 retry=3
netsh wins server \\{{ servername }} set pushparam state=1 strtup=0 addchange=0 update=0
netsh wins server \\{{ servername }} set pgmode Mode=0
netsh wins server \\{{ servername }} set autopartnerconfig state=0 interval=0 ttl=2
netsh wins server \\{{ servername }} set burstparam state=1 value=500
netsh wins server \\{{ servername }} set logparam dbchange=1 event=0
netsh wins server \\{{ servername }} set startversion version={0,0}

{%- for partner in wins_settings.partners -%}
  {%- if partner not in salt['grains.get']('ipv4') %}
netsh wins server \\{{ servername }} add partner server={{ partner }} type=0
netsh wins server \\{{ servername }} set pullpartnerconfig state=1 server={{ partner }} start=0 interval=1800

netsh wins server \\{{ servername }} add partner server={{ partner }} type=1
netsh wins server \\{{ servername }} set pushpartnerconfig state=1 server={{ partner }} update=0
  {% endif -%}
{%- endfor -%}
