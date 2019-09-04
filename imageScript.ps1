Set-executionpolicy -executionPolicy Unrestricted LocalMachine
Get-Process vpnui | stop-process -force
Copy-Item -Force -Recurse -Path D:\Cisco\ -Destination C:\ProgramData\
exec /i D:\asdfasdf.msi /quiet /qf /norestart /log C:\Temp\
add-computer -domainname global.com -Credential global\david.long
run \\lagprint\CanonPrint-LAGPRINT
