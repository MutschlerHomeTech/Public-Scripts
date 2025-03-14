#1. Query service status. Track its state.
sc query msiserver
sc query TrustedInstaller

#2. Stop/disable Windows Installer and Windows Module Installer services
sc stop msiserver
sc config msiserver start= disabled
sc stop TrustedInstaller
sc config TrustedInstaller start= disabled

#3. Backup ACLs for WinSxS folder.
icacls "%WINDIR%\WinSxS" /save "%WINDIR%\WinSxS.acl" /t

#4. Take ownership of WinSxS folder
takeown /f "%WINDIR%\WinSxS" /r

#5. Grant full rights on WinSxS to user
icacls "%WINDIR%\WinSxS" /grant "USERNAME7":(F) /t

#6. Compress Folders
compact /s:"%WINDIR%\WinSxS" /c /a /i *

#7. Restore ownership
icacls "%WINDIR%\WinSxS" /setowner "NT SERVICE\TrustedInstaller" /t

#8. Restore ACLs
icacls "%WINDIR%" /restore "%WINDIR%\WinSxS.acl"
del "%WINDIR%\WinSxS.acl"

#9. Restore services, replace "demand" and "start" with the right state
sc config msiserver start= auto
sc start msiserver
sc config TrustedInstaller start= auto
sc start TrustedInstaller