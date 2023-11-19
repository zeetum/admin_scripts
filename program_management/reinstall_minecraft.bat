SET dir=%cd%
powershell -noprofile -command "&{ start-process powershell -ArgumentList '-executionpolicy bypass -file %dir%\powershell_reinstall_minecraft.ps1' -verb RunAs}"
