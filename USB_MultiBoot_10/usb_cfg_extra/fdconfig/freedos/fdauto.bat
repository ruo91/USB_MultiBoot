@ECHO OFF
ctmouse.exe
ECHO ---------------------------------------------------------------------
ECHO All Prgs of DOSAPPS can be launched from Volkov Commander
ECHO Start Volkov Commander: type VC  and press [Enter]
ECHO ---------------------------------------------------------------------
PATH C:\DOSAPPS;C:\
echo PATH = %PATH%

for %%X in ( 1 3 5 7 ) do if "%config%"=="%%X" goto startmenu

C:\DOSDEV\SHSUCDX.COM /QQ /R /D:FDCD0000 /L:X

:startmenu
pause
SET COMSPEC=C:\FREEDOS\COMMAND.COM
C:
cd \
vc\vc.com
