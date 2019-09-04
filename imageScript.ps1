## Script to run after imaging as it configures and installs necessary programs missed by SCCM ##
## USB with essential files must be plugged in ##

Set-executionpolicy -executionPolicy Unrestricted LocalMachine
Get-Process vpnui | stop-process -force
Copy-Item -Force -Recurse -Path D:\Cisco\ -Destination C:\ProgramData\
exec /i D:\*.msi /quiet /qf /norestart /log C:\Temp\

## Adds Computer to Domain ##
add-computer -domainname global.com -Credential global\david.long

run \\lagprint\CanonPrint-LAGPRINT
