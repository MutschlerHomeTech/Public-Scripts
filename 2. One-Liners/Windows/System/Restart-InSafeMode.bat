#- Safe Mode:
bcdedit /set {default} safeboot minimal

#- Safe Mode with Networking:
bcdedit /set {default} safeboot network

#- Safe Mode with Command Prompt:
bcdedit /set {default} safebootalternateshell yes

#- Revert Safe Mode:
bcdedit /deletevalue {default} safeboot