## Script to run after user Logs Into Newly Imaged Machine ##

set-executionpolicy -ExecutionPolicy "ByPass"
net use T: \\lacentral\Applications /persistent:yes /savecred
net use S: \\lacentral\Planning /persistent:yes /savecred
start-process \\lagprint\CanonPrint-LAGPRINT
netsh wlan connect ssid=OMCGroup
D:\Scripts\SetDefaultPrinter.ps1 -PrinterName "CanonPrint-LAGPRINT"


