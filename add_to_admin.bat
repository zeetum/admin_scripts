@echo off
set /p eNumber=Enter eNumber: 
powershell.exe -NoProfile -ExecutionPolicy Unrestricted -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Unrestricted -Command Add-LocalGroupMember -Group "Administrators" -Member "INDIGO\%eNumber%" | Set-Service -StartupType Automatic' -Verb RunAs}";
