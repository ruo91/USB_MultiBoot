@echo off
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
::<---------------------------------------------------------------------
::<MakeBS.cmd Batch script to create a bootsector from current one
::<invoking NTLDR and make it invoke another loader such as SETUPLDR.BIN
::<(FAT16,FAT32 and NTFS partitions ONLY) Win2k/XP/2003 NO Win9.x/Me
::<It can optionally add a line invoking this bootsector in BOOT.INI 
::<IF a BOOT.INI is already present in the same partition
::<For NTFS partitions Loader name needs to be 5 char long
::<Release 0.07 ALPHA 01/October/2007
::<This script uses the functions of the DS File Ops Kit (DSFOK):
::<http://members.ozemail.com.au/~nulifetv/freezip/freeware/
::<This script by Jacopo Lazzari
::<http://home.graffiti.net/jaclaz:graffiti.net/
::<---------------------------------------------------------------------
::<
::<
IF %1.==. goto :HELP
IF NOT "%1."=="/?." goto :1STCHECK

:HELP
::<Command line usage:
::<MakeBS Driveletter:\NewLoader /A [BootIniEntryText]
::<Where:
::<Driveletter can be any letter assigned to a partition from C: to Z:
::<
::<Newloader is the filename of the loader, it must already exist on root
::<of the given Drive
::<
::<The output file will have the first part of the 8(+3) DOS given
::<name for NewLoader with the .BS extension
::< 
::<If you add the /A switch, the program will attempt adding
::<an entry to the BOOT.INI file on the given partition (if any)
::< 
::<If you add the [BootIniEntryText] as parameter, the program will use the 
::<supplied string instead of the default "Load Newloader bootsector" 
::< 
::<The supplied string MUST be enclosed in double quotes!
::<
::<A copy of Original Bootsector is made on root of Drive as "BackupBS.ori"
::< 
::<Examples:
::<MakeBS C:\SETUPLDR.BIN
::<Will create a file C:\btsec\SETUPLDR.BS and a file C:\btsec\BackupBS.ori
::< 
::<MakeBS C:\MYLDR /A
::<Will create a file C:\btsec\MYLDR.BS,a file C:\btsec\BackupBS.ori and add an entry in 
::<BOOT.INI as this: C:\btsec\MYLDR.BS="Load MYLDR bootsector"
::< 
::<MakeBS C:\ANOTHER.LDR /A "Start custom bootsector"
::<Will create a file C:\btsec\ANOTHER.BS AND add an entry in BOOT.INI as this:
::<C:\btsec\ANOTHER.BS="Start custom bootsector"
::<---------------------------------------------------------------------
CLS
TYPE MakeBS.cmd | Find /V "TYPE MakeBS.cmd"| Find "::<" | MORE
PAUSE
GOTO :EOF

:: Slightly Modified for Use with USB_MultiBoot3.cmd - BootSector File Dir = \btsec

:1STCHECK
SET WorkDrive=%~d0
SET WorkDir=%~dp0
SET Drive=%~d1
SET NewLoader=%~nx1
SET bsdir=\btsec
SET Switch=
IF NOT %2.==. SET Switch=%2
IF NOT %3.==. SET Entry=%3
%~d0
cd "%~dp0"
:: echo WorkDrive=%WorkDrive%
:: echo WorkDir=%WorkDir%
:: echo Drive=%Drive%
IF NOT EXIST %Drive%%bsdir%\nul MD %Drive%%bsdir%
:: pause
IF "%NewLoader%"=="SETUPLDR.BIN" GOTO :NOERROR
IF "%NewLoader%"=="PELDR" GOTO :NOERROR
IF "%NewLoader%"=="CMLDR" GOTO :NOERROR
IF "%NewLoader%"=="XPSTP" GOTO :NOERROR
IF NOT EXIST %Drive%\%Newloader% GOTO :ERROR1 %Drive%\%Newloader%

:NOERROR
IF NOT EXIST dsfo.exe CALL :ERROR1 dsfo.exe
IF DEFINED Switch IF /I NOT %Switch%.==/A. GOTO :ERROR2


SET Overwrite=NO
IF EXIST TempBSec.$$$ del TempBSec.$$$ >nul
dsfo \\.\%Drive% 0 512 TempBSec.$$$ >nul

:: Backup BootSector is Made by USB_MultiBoot.cmd - Change 8-2-2008 
:: FileCompare FC FAT 512 - Conflict with NTFS 8192 - skip FileCompare
GOTO :Skip_backup

IF EXIST %Drive%%bsdir%\BackupBS.ori (
FOR /F %%A IN ('FC %Drive%%bsdir%\BackupBS.ori TempBSec.$$$ ^| FIND "FC:"') DO ECHO. &ECHO BackupBS.ori existing and valid... &GOTO :Skip_backup
ECHO.
ECHO A file named BackupBS.ori already exists on drive %Drive%%bsdir%, though it's contents are
ECHO DIFFERENT from current bootsector.
ECHO Are you sure you want to overwrite it?
ECHO.
SET /P Overwrite=[Please enter YES in capital letters to confirm]
IF NOT !Overwrite!==YES GOTO :ERROR5
)
:: Moved copy 512 to FATOK - 12-2-2008
copy /B TempBSec.$$$ %Drive%%bsdir%\BackupBS.ori >nul

ECHO....
ECHO Current bootsector of drive %drive%\ backed up to %Drive%%bsdir%\BackupBS.ori
ECHO....


:Skip_backup
SET FAT=0
SET NTLDR=0

CALL :CheckBS 54 5 0 5 FAT FAT12
IF %FAT%.==FAT12. CALL :CheckBS 417 5 10 5 LDR NTLDR
IF %NTLDR%.==417. GOTO :FATOK

CALL :CheckBS 54 5 0 5 FAT FAT16
IF %FAT%.==FAT16. CALL :CheckBS 417 5 10 5 LDR NTLDR
IF %NTLDR%.==417. GOTO :FATOK

CALL :CheckBS 82 5 5 5 FAT FAT32
IF %FAT%.==FAT32. CALL :CheckBS 368 5 10 5 LDR NTLDR
IF %NTLDR%.==368. GOTO :FATOK

CALL :CheckBS 3 4 5 5 FAT NTFS
IF %FAT%.==NTFS. GOTO :NTFSOK

GOTO :Error3

:FATOK
:: Added MakeCopy TempBSec.$$$
copy /y /B TempBSec.$$$ %Drive%%bsdir%\BackupBS.ori >nul
ECHO Current bootsector appears to be %FAT%, "%LDR%" string found at offset %NTLDR%.
ECHO ...

CALL :Capitalize %NewLoader%

IF NOT %NewLoaderExt%.==. Set NewloaderExt=%NewloaderExt:.=%
IF %NewLoaderExt%.==. (SET /A MaxChar=11) ELSE (SET /A MaxChar=8)

Set BSName=%NewLoaderName%

SET toparse=%NewLoaderName%
SET /A counter=0
Call :Parseloop
SET NewLoaderName=%toparse%
IF %NewLoaderExt%.==. SET NewLoaderName=%NewLoaderName%   &GOTO :WriteFAT
SET /A MaxChar=3
SET toparse=%NewLoaderExt%
SET /A counter=0
Call :Parseloop
SET NewLoaderExt=%toparse%

:WriteFAT
ECHO %NewLoaderName%%NewLoaderExt%>TempName.$$$
dsfo TempBSec.$$$ 0 %NTLDR% TempHead.$$$>nul
dsfo TempName.$$$ 0 11 Temp_Ldr.$$$>nul
SET /A tail=%NTLDR% + 11
dsfo TempBSec.$$$ %tail% 0 TempTail.$$$>nul
copy /y /b TempHead.$$$+Temp_Ldr.$$$+TempTail.$$$ %Drive%%bsdir%\%BSName%.bs >nul
IF %ERRORLEVEL%==0 (CALL :Success) ELSE (GOTO :Error4)
IF /I "%Switch%"=="/A" GOTO :Addentry
GOTO :Cleantemp

:NTFSOK
ECHO Current bootsector appears to be %FAT%
ECHO ...

IF EXIST TempBSec.$$$ del TempBSec.$$$ >nul
dsfo \\.\%Drive% 0 8192 TempBSec.$$$ >nul
copy /y /B TempBSec.$$$ %Drive%%bsdir%\BackupBS.ori >nul
CALL :Capitalize %NewLoader%

IF NOT %NewLoaderExt%.==. GOTO :Error6
IF NOT %NewLoaderName:~0,5%==%NewLoaderName:~0,6% GOTO :Error7
SET /A MaxChar=5

Set BSName=%NewLoaderName%
SET toparse=%NewLoaderName%
SET /A counter=0
Call :Parseloop
SET NewLoaderName=%toparse%

IF EXIST 00.$$$ del 00.$$$ >nul
dsfo TempBSec.$$$ 513 1 00.$$$ >nul
ECHO %NewLoaderName%>newl.$$$

FOR %%A in (0 1 2 3 4) do dsfo newl.$$$ %%A 1 n%%A.$$$ >nul
copy /b n0.$$$ + 00.$$$ + n1.$$$ + 00.$$$ + n2.$$$ + 00.$$$ + n3.$$$ + 00.$$$+ n4.$$$ newl.$$$ >nul
dsfo TempBSec.$$$ 0 514 TempHead.$$$>nul
dsfo newl.$$$ 0 9 Temp_Ldr.$$$>nul
dsfo TempBSec.$$$ 523 0 TempTail.$$$>nul
copy /y /b TempHead.$$$+Temp_Ldr.$$$+TempTail.$$$ %Drive%%bsdir%\%BSName%.bs >nul
IF %ERRORLEVEL%==0 (CALL :Success) ELSE (GOTO :Error4)
IF /I "%Switch%"=="/A" GOTO :Addentry
GOTO :Cleantemp

:Addentry
IF NOT DEFINED Entry SET Entry="Load %NewloaderName% bootsector"
SET Entry=C:%bsdir%\%BSName%.bs=%Entry%
CALL :attribs %drive%\boot.ini
Find "C:%bsdir%\%BSName%.bs" %drive%\boot.ini>nul
IF !ERRORLEVEL!==0 ECHO Entry C:%bsdir%\%BSName%.bs already found, %Drive%\BOOT.INI NOT updated.&GOTO :Cleantemp
ECHO !Entry!>> %drive%\boot.ini
ECHO !Entry! added to %Drive%\BOOT.INI
ATTRIB !switches! %drive%\boot.ini>nul
GOTO :Cleantemp

:Capitalize
:: Capitalize
:: This routine has been published by Frank-Peter Schultze
:: http://www.fpschultze.de/smartfaq+faq.faqid+262.htm
:: and slightly simplified by me

Set s=%1

For %%A In (
  aA bB cC dD eE fF gG hH iI
  jJ kK lL mM nN oO pP qQ rR
  sS tT uU vV wW xX yY zZ
) Do Call :UCase %%A

Call :NewLoaderSplit %s%
GOTO :EOF

:UCase
Set _=%1
Call Set s=%%s:%_:~0,1%=%_:~1,1%%%
Goto :EOF

:NewLoaderSplit
Set NewloaderName=%~n1
Set NewloaderExt=%~x1
Goto :EOF

:CheckBS
dsfo TempBSec.$$$ %1 %2 TempFile.$$$ >nul
FIND "%6" TempFile.$$$>nul
ECHO ...
IF %ERRORLEVEL%==0 (
Set %5=%6
SET %6=%1
) 
del TempFile.$$$
GOTO :EOF

:ParseLoop
Set /A counter=%counter%+1
Set len=!toparse:~0,%counter%!
IF NOT %counter%==%MaxChar% SET toparse=%toparse% &goto :ParseLoop
SET toparse=%len%
GOTO :EOF


:attribs
SET attribs=%~a1
ATTRIB -h -r -s %drive%\boot.ini
Set IsR=%attribs:~1,1%
Set IsH=%attribs:~3,1%
Set IsS=%attribs:~4,1%
For %%A in (%IsR% %IsH% %IsS%) DO IF NOT "%%A"=="-" SET Switches=%Switches% +%%A
GOTO :EOF

:Success
ECHO ...
ECHO New bootsector %Drive%%bsdir%\%BSName%.bs created succesfully
ECHO ...
GOTO :EOF

:Cleantemp
For %%A in ( Name BSec Head _Ldr Tail File ) DO IF EXIST Temp%%A.$$$ DEL Temp%%A.$$$>nul
FOR %%A in (00 n0 n1 n2 n3 n4 newl) do IF EXIST %%A.$$$ DEL %%A.$$$>nul
GOTO :EOF

:ERROR1
Echo A needed file is missing
Echo File %1 is missing
pause
GOTO :HELP

:ERROR2
Echo Given parameters are wrong
Pause
GOTO :HELP

:ERROR3
Echo Program aborted! - wrong filesystem or bootsector type
pause
GOTO :Cleantemp

:ERROR4
Echo Error! Could not write bootsector %Drive%%bsdir%\%BSName%.bs
Pause
GOTO :Cleantemp

:ERROR5
Echo Batch aborted by user
Pause
GOTO :Cleantemp

:ERROR6
CLS
ECHO No extension allowed for loaders on NTFS partitions
ECHO You need to rename the loader from:
ECHO %NewLoaderName%%NewLoaderExt%
ECHO to:
ECHO %NewLoaderName:~0,5%
ECHO and re-run the batch
Pause
GOTO :Cleantemp

:ERROR7
Echo Only five characters allowed for loaders on NTFS partitions
ECHO You need to rename the loader from:
ECHO %NewLoaderName%
ECHO to:
ECHO %NewLoaderName:~0,5%
ECHO and re-run the batch
Pause
GOTO :Cleantemp

