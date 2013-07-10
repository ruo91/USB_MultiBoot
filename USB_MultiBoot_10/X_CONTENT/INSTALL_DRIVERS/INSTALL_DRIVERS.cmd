TITLE DriverPacks - INSTALL_DRIVERS.CMD
CLS
@echo off

:: Check Windows version
IF NOT "%OS%"=="Windows_NT"  (
  ECHO.
  ECHO ***** ONLY for Windows XP OR Windows 2003 *****
  ECHO.
  GOTO _end_quit
)

set win_vista=0
:: Vista checks ::::::::::::
VER | find "6.0." > nul
IF %errorlevel% EQU 0 SET win_vista=1

SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

SET dpdrive=
SET dpsource=DriverPacks
SET dp_flag=1
SET unpak_flag=0
SET dr_folder=
set _fselpath=%~p0
SET dpfree=

:_unpack_menu
echo.
echo  Supports Post XP Setup Install of Drivers with Device Manager by
echo  Unpacking DriverPacks or OEM Source Folder to Selected Target Drive
echo  And by Setting DevicePath to Selected Target Driver Folder
echo.
ECHO  DriverPacks From http://driverpacks.net/DriverPacks/overview.php
echo.
echo.
echo     1) Change DriverPacks Source,   currently [%dpsource%]
echo.
echo     2) Change Target Drive,         currently [%dpdrive%]
echo.     
echo     3) Unpack  All    DriverPacks To   Target Drive
echo.
echo     4) Unpack Selected DriverPack To   Target Drive and Install Drivers
echo.
echo     5) Use Existing   DriverPacks From Target Drive for Install Drivers
echo.
echo     Q) Quit - END Program
echo.
echo  Vista requires to turn User Account Control OFF 
echo.

set _ok=
set /p _ok= Enter your choice: 
if /I "%_ok%" == "1" goto _getsource
if /I "%_ok%" == "2" goto _getdrive
if /I "%_ok%" == "3" goto _unpak
if /I "%_ok%" == "4" goto _getdp
if /I "%_ok%" == "5" goto _usedp
if /I "%_ok%" == "q" goto _end_quit
ECHO.
ECHO ***** NOT in Menu - Wrong Selection - Try Again *****
ECHO.
pause
goto :_unpack_menu


:_getsource
set src_ok=
echo.
echo  Please Select your DriverPacks Source Folder

IF EXIST u_script\FolderSel.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSel.vbs') DO SET src_ok=%%A
) ELSE (
  ECHO  e.g if you have Type   D:\DriverPacks
  set /p src_ok= Enter DriverPacks Source Path: 
)
ECHO.

IF "%src_ok%" == "" goto :_unpack_menu

ECHO %src_ok%|FIND " "
IF "%ERRORLEVEL%"=="0" (
  echo.
  echo  ***** Error: Selected Path does Contain Spaces and is Invalid *****
  echo.
  echo     Solution: Rename Folder or Change to Path without Spaces
  echo.
  pause
  goto :_unpack_menu
)

IF EXIST %src_ok%\DP*.7z (
  SET dpsource=%src_ok%
) ELSE (
  echo.
  echo  SELECTED %src_ok%
  echo  Error: Selected Folder does not Contain DriverPacks
  echo.
  pause
  goto :_unpack_menu
)
goto :_unpack_menu


:_getdrive
set _ok=
set drlist=
SET dpdrive=

IF %win_vista% EQU 0 (
  FOR /F "tokens=*" %%a in ('fsutil fsinfo drives ^| FIND /V ""') DO (
    set dr=%%a
    SET dr=!dr:~-3,3!
    SET cdr=!dr:~0,1!
    IF !cdr! GTR B (
      FOR /F "tokens=1 delims= " %%G IN ('fsutil fsinfo volumeinfo !dr! ^| FINDSTR "FAT NTFS"') DO (
        SET vname=%%G
        SET vname=!vname:~0,1!
        IF !vname! NEQ V call set drlist=%%drlist%% %%dr:~0,2%%
      )
    )
  )
) ELSE (
  FOR /F "tokens=1,* delims= " %%a in ('fsutil fsinfo drives') DO set vdrlist=%%b
  FOR %%C IN (!vdrlist!) DO (
    SET dr=%%C
    SET cdr=!dr:~0,1!
    IF !cdr! GTR B (
      FOR /F "tokens=1 delims= " %%G IN ('fsutil fsinfo volumeinfo !dr! ^| FINDSTR "FAT NTFS"') DO (
        SET vname=%%G
        SET vname=!vname:~0,1!
        IF !vname! NEQ V call set drlist=%%drlist%% %%dr:~0,2%%
      )
    )
  )
)

echo.
echo  FAT FAT32 NTFS DriveList =%drlist%
echo.
echo.
echo  Select DriverPacks Target Drive from DriveList
ECHO.

IF EXIST u_script\FolderSel.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSel.vbs') DO SET _ok=%%A
  set _ok=!_ok:~0,1!
) ELSE (
  set /p _ok= Enter Target Drive Letter: 
  IF "!_ok!"=="" (
    echo.
    echo  ***** Drive is NOT Valid *****
    echo.
    pause
    goto :_unpack_menu
  )
  set _ok=!_ok:~0,1!

  set /A chtel=0
  set /A uptel=0
  FOR %%i IN (d e f g h i j k l m n o p q r s t u v w x y z) DO (
    set /A chtel=!chtel!+1
    IF "%%i" == "!_ok!" (
      FOR %%i IN (D E F G H I J K L M N O P Q R S T U V W X Y Z) DO (
        set /A uptel=!uptel!+1
        IF "!uptel!" == "!chtel!" (
           SET _ok=%%i
           goto _ucase
        )
      )
    )
  )
)

:_ucase

FOR %%i IN (%drlist%) DO IF "%%i" == "!_ok!:" SET dpdrive=!_ok!:

goto :_unpack_menu


:_unpak
IF "%dpdrive%" == "" (
  echo.
  echo  ***** Please First Select DriverPacks Target Drive *****
  echo.
  pause
  goto :_unpack_menu
)

IF EXIST %dpsource%\DP*.7z (
  ECHO  Decompression Of DriverPacks      Please Wait .....
  start /wait bin\7z.exe x -y -aoa %dpsource%\DP*.7z -o"%dpdrive%"
  ECHO.
  ECHO  Decompression Of DriverPacks      Finished
  SET unpak_flag=1
) ELSE (
  ECHO.
  ECHO  ***** ERROR - DriverPacks NOT Found *****
  ECHO.
  pause
  goto :_unpack_menu
)

goto :_unpack_menu

:_getdp
IF "%dpdrive%" == "" (
  echo.
  echo  ***** Please First Select DriverPacks Target Drive *****
  echo.
  pause
  goto :_unpack_menu
)
IF "%unpak_flag%"=="0" SET unpak_flag=2

ECHO %dpsource%|FIND "OEM"
IF "%ERRORLEVEL%"=="0" (
  SET dp_flag=0
) ELSE (
  SET dp_flag=1
)
goto :_dp_menu

:_usedp
IF "%dpdrive%" == "" (
  echo.
  echo  ***** Please First Select DriverPacks Target Drive *****
  echo.
  pause
  goto :_unpack_menu
)
SET unpak_flag=0
goto :_dp_menu


:_dp_menu
echo.
echo  Make DriverPack Selection for Install of Driver
echo.
echo   1 = Chipset
echo.
echo   2 = CPU
echo.
echo   3 = Graphics A
echo   4 = Graphics B
echo   5 = Graphics C
echo.
echo   6 = LAN
echo.
echo   7 = MassStorage
echo.
echo   8 = Sound A
echo   9 = Sound B
echo.
echo   A = WLAN
echo.
echo   F = Free Select Custom Driver Folder containing needed Drivers only
echo.
echo   Q = END Program - Reset DevicePath - Needed - Restart Your Computer
echo.

set _ok=
set /p _ok= Enter your choice: 
IF "%dp_flag%"=="0" (
  if /I "%_ok%" == "1" CALL :_driver_install %unpak_flag% DPC*.7z C Chipset
  if /I "%_ok%" == "2" CALL :_driver_install %unpak_flag% DPCP*.7z CPU CPU
  if /I "%_ok%" == "3" CALL :_driver_install %unpak_flag% DPGA*.7z G Graphics_A
  if /I "%_ok%" == "4" CALL :_driver_install %unpak_flag% DPGB*.7z G Graphics_B
  if /I "%_ok%" == "5" CALL :_driver_install %unpak_flag% DPGC*.7z G Graphics_C
  if /I "%_ok%" == "6" CALL :_driver_install %unpak_flag% DPL*.7z L LAN
  if /I "%_ok%" == "7" CALL :_driver_install %unpak_flag% DPM*.7z M MassStorage
  if /I "%_ok%" == "8" CALL :_driver_install %unpak_flag% DPSA*.7z S Sound_A
  if /I "%_ok%" == "9" CALL :_driver_install %unpak_flag% DPSB*.7z S Sound_B
  if /I "%_ok%" == "A" CALL :_driver_install %unpak_flag% DPW*.7z W WLAN
) ELSE (
  if /I "%_ok%" == "1" CALL :_driver_install %unpak_flag% DP_Chipset*.7z C Chipset
  if /I "%_ok%" == "2" CALL :_driver_install %unpak_flag% DP_CPU*.7z CPU CPU
  if /I "%_ok%" == "3" CALL :_driver_install %unpak_flag% DP_Graphics_A*.7z G Graphics_A
  if /I "%_ok%" == "4" CALL :_driver_install %unpak_flag% DP_Graphics_B*.7z G Graphics_B
  if /I "%_ok%" == "5" CALL :_driver_install %unpak_flag% DP_Graphics_C*.7z G Graphics_C
  if /I "%_ok%" == "6" CALL :_driver_install %unpak_flag% DP_LAN*.7z L LAN
  if /I "%_ok%" == "7" CALL :_driver_install %unpak_flag% DP_MassStorage*.7z M MassStorage
  if /I "%_ok%" == "8" CALL :_driver_install %unpak_flag% DP_Sound_A*.7z S Sound_A
  if /I "%_ok%" == "9" CALL :_driver_install %unpak_flag% DP_Sound_B*.7z S Sound_B
  if /I "%_ok%" == "A" CALL :_driver_install %unpak_flag% DP_WLAN*.7z W WLAN
)
if /I "%_ok%" == "F" CALL :_getfree
if /I "%_ok%" == "q" goto :Einde
:: ECHO.
:: ECHO ***** NOT in Menu - Wrong Selection - Try Again *****
ECHO.
pause
goto :_dp_menu

:_driver_install
IF "%1"=="2" (
  IF EXIST %dpsource%\%2 (
    ECHO  Decompression Of DriverPacks      Please Wait .....
    start /wait bin\7z.exe x -y -aoa %dpsource%\%2 -o"%dpdrive%"
    ECHO  Decompression Of DriverPacks      Finished
  ) ELSE (
    ECHO.
    ECHO  ***** ERROR - DriverPacks NOT Found *****
    ECHO  Folder %dpsource%\%2 does NOT Exist
    ECHO.
    goto :EOF
  )
) ELSE (
  IF NOT EXIST %dpdrive%\D\%3\nul (
    ECHO.
    ECHO  ***** ERROR - DriverPack %4 NOT Found *****
    ECHO  Folder %dpdrive%\D\%3 does NOT Exist
    ECHO.
    goto :EOF
  ) ELSE (
    ECHO.
    ECHO.
  )
)

start /wait bin\SetDevicePath %dpdrive%\D\%3

ECHO  DevicePath was Set to %dpdrive%\D\%3
ECHO.
ECHO  Device Manager : R-Mouse Device - Select Driver Update ....
ECHO  Wizard Hardware: NO WinUpdate and Automatic Install of Driver Software
ECHO.
ECHO  After Driver Update Close Device Manager and Select Next Driver Type from Menu  
IF EXIST u_script\Msg_Driver_Install.vbs (
  CSCRIPT.EXE //NoLogo u_script\Msg_Driver_Install.vbs>nul
)
start /wait devmgmt.msc
GOTO :EOF

:_getfree
set src_ok=
SET dpfree=
IF "%unpak_flag%"=="2" (
  ECHO.
  ECHO  Select DriverPacks File DP*.7z From %dpsource%
  ECHO.
  IF %win_vista% EQU 0 (
    IF EXIST u_script\FileSel_7z.vbs (
      FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FileSel_7z.vbs %_fselpath%\%dpsource%') DO SET src_ok="%%A"
    ) ELSE (
      ECHO  e.g Type D:\USB_MultiBoot_8\X_CONTENT\INSTALL_DRIVERS\DriverPacks\DP_ASUS.7z
      set /p src_ok= Enter DriverPacks FileName and Path: 
    )
  ) ELSE (
    ECHO  e.g Type D:\USB_MultiBoot_8\X_CONTENT\INSTALL_DRIVERS\DriverPacks\DP_ASUS.7z
    set /p src_ok= Enter DriverPacks FileName and Path: 
  )
  
  IF "!src_ok!"=="" GOTO :_dp_menu
  IF NOT EXIST !src_ok! (
    ECHO.
    ECHO  ***** ERROR - DriverPacks File does NOT Exist - Select Again *****
    ECHO.
    pause
    GOTO :_dp_menu
  )

  SET dpfree=!src_ok!
  ECHO  Decompression Of DriverPacks      Please Wait .....
  start /wait bin\7z.exe x -y -aoa !dpfree! -o"%dpdrive%"
  ECHO.
  ECHO  Decompression Of DriverPacks      Finished
  SET unpak_flag=1
  pause
)


set src_ok=
echo.
echo  Please Select your Drivers Source Folder

IF EXIST u_script\FolderSel.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSel.vbs') DO SET src_ok=%%A
) ELSE (
  ECHO  e.g if you have Type   C:\Drivers
  set /p src_ok= Enter Drivers Source Path: 
)
ECHO.

IF "%src_ok%" == "" goto :_dp_menu

ECHO %src_ok%|FIND " "
IF "%ERRORLEVEL%"=="0" (
  echo.
  echo  ***** Error: Selected Path does Contain Spaces and is Invalid *****
  echo.
  echo     Solution: Rename Folder or Change to Path without Spaces
  echo.
  pause
  goto :_dp_menu
)

SET drfolder=%src_ok%


start /wait bin\SetDevicePath %drfolder%

ECHO  DevicePath was Set to %drfolder%
ECHO.
ECHO  Device Manager : R-Mouse Device - Select Driver Update ....
ECHO  Wizard Hardware: NO WinUpdate and Automatic Install of Driver Software
ECHO.  
IF EXIST u_script\Msg_Driver_Install.vbs (
  CSCRIPT.EXE //NoLogo u_script\Msg_Driver_Install.vbs>nul
)
start /wait devmgmt.msc
GOTO :EOF


:Einde
ECHO.
start /wait REGEDT32.EXE /S bin\DevicePath_Reset.reg
ECHO  END Program - DevicePath was RESET to WINDOWS\inf Folder
ECHO.

:_end_quit
ECHO.
ECHO  END Program - Driver_INSTALL will be Closed
ECHO.
PAUSE
EXIT
