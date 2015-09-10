{% from "w32time/map.jinja" import w32time_settings with context %}

w32time:
  service.running:
    - names: {{ w32time_settings.services|yaml }}
    - enable: True
  cmd.wait:
    - name: w32tm /config /update
    - require:
        - service: w32time

HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters\Type:
  reg.present:
    - vtype: REG_SZ
    - value: {{ "NTP" if w32time_settings.authoritative else "NT5DS" }}
    - watch_in:
        - cmd: w32time

HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Config\AnnounceFlags:
  reg.present:
    - vtype: REG_DWORD
    - value: {{ w32time_settings.announce_flag if w32time_settings.authoritative else '0xA' }}
    - watch_in:
        - cmd: w32time

HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpServer:
  reg.present:
    - vtype: REG_DWORD
    - value: {{ 1 if w32time_settings.authoritative else 0 }}
    - watch_in:
        - cmd: w32time

HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters\NtpServer:
  reg.present:
    - vtype: REG_SZ
    - value: {{ w32time_settings.ntp_peers|join(' ') if w32time_settings.authoritative else 'time.windows.com,0x1' }}
    - watch_in:
        - cmd: w32time

HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient\SpecialPollInterval:
  reg.present:
    - vtype: REG_DWORD
    - value: {{ w32time_settings.special_poll_interval if w32time_settings.authoritative else 3600 }}
    - watch_in:
        - cmd: w32time

HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Config\MaxPosPhaseCorrection:
  reg.present:
    - vtype: REG_DWORD
    - value: {{ w32time_settings.max_pos_phase_correction if w32time_settings.authoritative else 172800 }}
    - watch_in:
        - cmd: w32time

HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Config\MaxNegPhaseCorrection:
  reg.present:
    - vtype: REG_DWORD
    - value: {{ w32time_settings.max_pos_phase_correction if w32time_settings.authoritative else 172800 }}
    - watch_in:
        - cmd: w32time
