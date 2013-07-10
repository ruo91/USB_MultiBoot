:: ========================================================================================================
:: ====================================== CMDCONS_Folder3.cmd - 14 mar 2008 ===============================
:: ========================================================================================================
::
:: Makes usb_cmdcons Folder to be copied to USB-Drive as folder cmdcons
:: To make Recovery Console is Required:
:: - Additional winnt_rec.sif file  to be placed in cmdcons Folder as File winnt.sif
:: - Additional XPSOURCE\I386\SETUPLDR.BIN File to be placed in Root Dir as File CMLDR
:: - Additional BOOTSECT.DAT file in cmdcons folder = Bootsector File USB-Drive e.g. CMBOOT.bs in btsec Folder
:: Rule to be added to boot.ini 
:: C:\CMDCONS\BOOTSECT.DAT="Recovery Console Windows XP" /cmdcons
:: OR  C:\btsec\CMBOOT.bs="0. Recovery Console Windows XP" /cmdcons
::
:: ======================== winnt_rec.sif File for Recovery Console =======================================
:: ;
:: ; winnt_rec.sif File for Recovery Console to be placed in cmdcons Folder as File winnt.sif
:: ;
:: ; Change Language to your needs - Language=00000413 is Dutch
:: ;
:: [data]
:: msdosinitiated="1"
:: floppyless="1"
:: CmdCons="1"
:: AutoPartition="0"
:: UseSignatures="yes"
:: InstallDir="\WINDOWS"
:: EulaComplete="1"
:: winntupgrade="no"
:: win9xupgrade="no"
:: Win32Ver="a280105"
:: uniqueid="C:\WINDOWS\FBN"
:: OriSrc="D:\XPROF7_710\"
:: OriTyp="3"
:: [regionalsettings]
:: ; Language=00000413
:: LanguageGroup=1
:: [setupparams]
:: DynamicUpdatesWorkingDir=C:\WINDOWS\setupupd
:: [unattended]
:: unused=unused
:: [userdata]
:: productid=""
:: productkey=""
:: [OobeProxy]
:: Enable=1
:: Flags=1
:: Autodiscovery_Flag=4
:: 
:: ======================== END winnt_rec.sif Files =======================================================
:: 
@ECHO OFF
CLS
:: Check Windows version
IF NOT "%OS%"=="Windows_NT" GOTO Syntax

SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

:: Give XP Source Directory with Location of DOSNET.INF
SET xpsource=
SET bttarget=
SET btdir=usb_cmdcons

IF "%btdir%" == "" (
        echo.
        echo  Bootfolder Name NOT Valid
        echo.
	goto _end_quit
)

:_main
ECHO.
ECHO  CMDCONS_Folder.cmd Batch Program for Windows XP - 14 mar 2008
echo.
echo  Parse DOSNET.INF for making Windows XP Recovery Console Folder
echo.
echo     1) Change Windows XP Source Path  , currently [%xpsource%]
echo.
echo     2) Change Destination Directory   , currently [%bttarget%]
echo.
echo     3) Make Target Windows XP Recovery Console Folder %btdir%
echo.
echo     Q) Quit
echo.

set _ok=
set /p _ok= Enter your choice: 
if "%_ok%" == "1" goto _getsrc
if "%_ok%" == "2" goto _gettmp
if "%_ok%" == "3" goto _mktemp
if /I "%_ok%" == "q" goto _end_quit
ECHO.
ECHO ***** NOT in Menu - Wrong Selection - Try Again *****
ECHO.
pause
goto :_main

:_getsrc
set src_ok=
echo.
echo  Please give the location to your Windows XP Source Files
ECHO  e.g if you have C:\XPSOURCE\I386 type C:\XPSOURCE
ECHO.
set /p src_ok= Enter Source path: 
ECHO.
ECHO %src_ok%|FIND " "
IF "%ERRORLEVEL%"=="0" (
  echo.
  echo  ***** Error: Selected Path does Contain Spaces and is Invalid *****
  echo.
  echo     Solution: Rename Folder or Change to Path without Spaces
  echo.
  pause
  goto _main
)
if exist %src_ok%\i386\nul (
        SET xpsource=%src_ok%
) else (
	echo.
	echo  Error: The path %src_ok% does not contain Windows XP Source Files
        echo.
	pause
)
goto _main

:_gettmp
set _ok=
echo.
echo  Give Target Directory Path for making Recovery Console Folder %btdir%
ECHO.
set /p _ok= Enter Target Directory Path: 
if exist !_ok!\nul (
  SET bttarget=!_ok!
  if EXIST !bttarget!\%btdir%\nul (
        echo.
	echo  ***** WARNING Existing XP  RC-Folder %btdir% Detected   *****
        echo  ***** Files will be Replaced when Making %btdir% Folder *****
        echo.
	pause
  )
) ELSE (
  echo  Directory Path !_ok! Does NOT Exists, Make Selection Again
  echo.
  pause
)
goto _main

:_mktemp
IF "%xpsource%" == "" (
        echo  Please give first valid XP Source Path
        echo.
	pause
	goto _main
)

IF "%bttarget%" == "" (
        echo  Please give first valid Destination Directory
        echo.
	pause
	goto _main
)

:: Make Destination directories for XP Setup Bootfolder
IF NOT EXIST %bttarget%\%btdir%\nul MD %bttarget%\%btdir%
IF NOT EXIST %bttarget%\%btdir%\system32\nul MD %bttarget%\%btdir%\system32


SET cpyflag=0
FOR /F "tokens=1,2,3* delims=, " %%G IN (%xpsource%\I386\DOSNET.INF) DO (
  SET FTAG=%%G
  SET FTAG=!FTAG:~0,13!
  IF "!FTAG!"=="[FloppyFiles." ( 
    SET cpyflag=1
    IF "%%G"=="[FloppyFiles.x]" SET cpyflag=0
  ) ELSE (
    SET FTAG=!FTAG:~0,1!
    IF "!FTAG!"=="[" SET cpyflag=0
    IF "!cpyflag!"=="1" (
      SET btfile=%%H
      IF "%%I"=="" (
         SET btfile=!btfile:~0,-1!*
         xcopy %xpsource%\I386\!btfile! %bttarget%\%btdir% /i /k /y /h
      ) ELSE (
         copy /y %xpsource%\I386\%%H %bttarget%\%btdir%\%%I
      )
    ) 
  )
)

SET cpyflag=0
FOR /F "tokens=1,2* delims== " %%G IN (%xpsource%\I386\DOSNET.INF) DO (
  SET FTAG=%%G
  IF "!FTAG!"=="[CmdConsFiles]" ( 
    SET cpyflag=1
  ) ELSE (
    SET FTAG=!FTAG:~0,1!
    IF "!FTAG!"=="[" SET cpyflag=0
    IF "!cpyflag!"=="1" (
      copy /y %xpsource%\I386\%%G %bttarget%\%btdir%
    ) 
  )
)

ECHO.
ECHO  Making cmdcons Recovery Console Folder %bttarget%\%btdir% - READY
GOTO :_end_quit

:Syntax
ECHO.
ECHO  CMDCONS_Folder.cmd,  Version 1.0 for Windows XP
ECHO.
ECHO  Parse DOSNET.INF for making Windows XP Recovery Console Folder cmdcons
ECHO.

:_end_quit
ECHO.
ECHO  End CMDCONS_Folder.cmd Batch Program
ECHO.
pause
EXIT

:: ========================================================================================================
:: ====================================== END CMDCONS_Folder.cmd ==========================================
:: ========================================================================================================
