@echo off
SET TZ=GHO-01:00
rem Bootable USB-stick - MS-DOS Boot Floppy Image - Bootdrive= A:
set cddrv=
set srcdrv=A:
set prgdrv=A:
echo AUTOEXEC: Booted drive is %srcdrv%

ctmouse.exe

:startmenu
rem set prgdrv=A:
PATH %prgdrv%\DOSAPPS;%prgdrv%\DOSPRG;%srcdrv%\;%srcdrv%\DOS
SET COMSPEC=%srcdrv%\COMMAND.COM
echo CD-drive= %cddrv%  PRG-drive= %prgdrv%  PATH= %PATH%
echo Press Any Key for Program Selection Menu . . . .
pause

:MENU
cls
%prgdrv%
cd \
echo.
echo CD-drive= %cddrv%  PRG-drive= %prgdrv%  PATH= %PATH%
echo.
echo Make Program Selection: Available = 1 7 A C D E
echo 1 = Ghost 2003 - System Image Backup
echo 2 = Uneraser - File Recovery
echo 3 = Start NTFSPRO - Read / Write
echo 4 = SCANDISK
echo 5 = Partition Magic 8.0
echo 6 = Partition Info
echo 7 = Win XP Password Changer
echo 8 = Partition Table Doctor - Recovery
echo 9 = Volkov Commander - File Manager
echo A = Partition Table Editor
echo B = Norton Diskedit
echo C = MBR Tool - Master Boot Record
echo D = DOS Prompt, with FORMAT
echo E = KILLDISK Pro - Disk Eraser
echo F = NTFS Reader - Copy files to FAT drives
echo G = Partition Recovery
echo H = MS-DOS File Editor

%srcdrv%\choice.com /c123456789ABCDEFGH  Give Your Choice:
if errorlevel 17 GOTO MED
if errorlevel 16 GOTO APR
if errorlevel 15 GOTO NTR
if errorlevel 14 GOTO DSK
if errorlevel 13 GOTO QUIT
if errorlevel 12 GOTO NDD
if errorlevel 11 GOTO DED
if errorlevel 10 GOTO PTE
if errorlevel 9 GOTO VCM
if errorlevel 8 GOTO TED
if errorlevel 7 GOTO FDK
if errorlevel 6 GOTO PIN
if errorlevel 5 GOTO PM8
if errorlevel 4 GOTO SCA
if errorlevel 3 GOTO NTFSPR
if errorlevel 2 GOTO UNE
if errorlevel 1 GOTO NGH
echo.
GOTO MENU

:NGH
%prgdrv%
cd \DOSPRG
GHOST.EXE
GOTO MENU

:UNE
%prgdrv%
cls
cd \dosapps\uneraser
uneraser.exe
GOTO MENU

:NTFSPR  
%prgdrv%
cd \DOSPRG\NTFSPRO
ntfspro.exe
cd \
echo Press Any Key for Program Selection Menu . . . .
pause
GOTO MENU

:SCA
%prgdrv%
cd \DOSPRG
SCANDISK.EXE /ALL
GOTO MENU

:PM8
echo Please wait ....
%prgdrv%
cd \DOSPRG\PM8
PQMAGIC.EXE
GOTO MENU

:PIN
%prgdrv%
cd \DOSPRG
PARTINFO.EXE | SHOW.COM
GOTO MENU

:FDK
%prgdrv%
cls
cd \dosapps\pwd_chng
pwd_chng.exe
GOTO MENU

:TED
%prgdrv%
cls
cd \dosapps\ptdoctor
ptd.exe
GOTO MENU 

:VCM
%prgdrv%
cd \VC
VC.COM
GOTO MENU

:PTE
%prgdrv%
cd \DOSPRG
PTEDIT.EXE
GOTO MENU

:DED
%prgdrv%
cd \DOSPRG
DISKEDIT.EXE
GOTO MENU

:NDD
%prgdrv%
cls
cd \dosapps\mbrtool
mbrtool.exe
GOTO MENU

:DSK
%prgdrv%
cls
cd \dosapps\killdisk
killdisk.exe
GOTO MENU 

:NTR
%prgdrv%
cls
cd \dosapps\readntfs
READNTFS.EXE
GOTO MENU 

:APR
%prgdrv%
cls
cd \dosapps\pr
pr.exe
GOTO MENU 

:MED
%prgdrv%
cls
cd \DOSPRG
EDIT.COM
GOTO MENU 

:QUIT
%srcdrv%
cd \
PATH %prgdrv%\DOSAPPS;%prgdrv%\DOSPRG;%srcdrv%\;%srcdrv%\DOS
ECHO ---------------------------------------------------------------------
ECHO All Prgs of DOSPRG and DOSAPPS can be launched from Volkov Commander
rem ECHO Start Volkov Commander: type  VC            and  press [Enter]
echo Start Program Menu    : type  AUTOEXEC.BAT  and  press [Enter]
ECHO ---------------------------------------------------------------------
echo CD-drive= %cddrv%  PRG-drive= %prgdrv%  PATH= %PATH%
echo.
