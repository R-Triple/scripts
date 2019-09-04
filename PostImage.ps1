set-executionpolicy -ExecutionPolicy "ByPass"
net use T: \\lacentral\Applications /persistent:no /savecred
net use S: \\lacentral\Planning /persistent:no /savecred
start-process \\lagprint\CanonPrint-LAGPRINT
netsh wlan connect ssid=OMCGroup
D:\Scripts\SetDefaultPrinter.ps1 -PrinterName "CanonPrint-LAGPRINT"


