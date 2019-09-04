##V. 1.2##
##edited by Adam Latz 9/26/2018##

@echo off
echo Username=%UserName%

net use /del B: /y
net use /del L: /y
net use /del M: /y
net use /del N: /y
net use /del O: /y
net use /del W: /y
net use /del x: /y
net use /del Y: /y
net use /del Z: /y

net use /del \\naidceft\e$\ftps\dds-cmv\backup /Y
net use /del \\Lacentral\applications\repository21 /Y
net use /del \\Lacentral2\applications\repository21 /Y
net use /del \\Lacentral3\applications\repository21 /Y
net use /del \\Lacentral4\applications\repository21 /Y
net use /del \\laphdfp\phdapps\repository21 /Y
net use /del \\sfcentral\applications\repository21 /Y
net use /del \\sffp\applications\repository21 /Y
net use /del \\seacentral\applications\repository21 /Y

net use B: \\naidceft\e$\ftps\dds-cmv\backup /user:global\globalscape Gl0b@l5cap3
net use L: \\Lacentral\applications\repository21 /Y
net use M: \\Lacentral2\applications\repository21 /Y
net use N: \\Lacentral3\applications\repository21 /Y
net use O: \\Lacentral4\applications\repository21 /Y
net use W: \\laphdfp\phdapps\repository21 /Y
net use X: \\sfcentral\applications\repository21 /Y
net use Y: \\sffp\applications\repository21 /Y
net use Z: \\seacentral\applications\repository21 /Y

cls

REM "Backing up the INI file to GlobalScape and Creation of Dummy File"
copy L:\cmv.ini B:\cmv-%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%-%username:~0,20%.txt
copy L:\cmv.ini L:\cmv.dum /Y

REM "Locking file for editing"
START notepad L:\cmv.dum
@echo User %username% locked the CMV.ini file for editing on %date% at %time% >> L:\log_lock.txt

set /p DUMMY=Hit ENTER to contimue...

copy L:\cmv.dum L:\cmv.ini /Y
del L:\cmv.dum /Q

REM "Copying CMV from Master to Slaves Drives"

copy L:\CMV.ini M: /Y
copy L:\CMV.ini N: /Y
copy L:\CMV.ini O: /Y
copy L:\CMV.ini W: /Y
copy L:\CMV.ini X: /Y
copy L:\CMV.ini Y: /Y
copy L:\CMV.ini Z: /Y

pause

REM "Unounting Drives if in use"

C:
net use /del B: /y
net use /del L: /y
net use /del M: /y
net use /del N: /y
net use /del O: /y
net use /del W: /y
net use /del x: /y
net use /del Y: /y
net use /del Z: /y

pause

Exit