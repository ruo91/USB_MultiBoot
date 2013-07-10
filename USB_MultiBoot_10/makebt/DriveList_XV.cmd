@ECHO OFF
CLS
ECHO  Program  -  DriveList_XV.CMD  -  12 feb 2008 - Date = %DATE% %TIME:~0,8%

:: Check Windows version
IF NOT "%OS%"=="Windows_NT" (
  ECHO ***** ONLY for Windows XP OR Windows 2003 *****
  GOTO :_end_quit
)

set win_vista=0
:: Vista check
VER | find "6.0." > nul
IF %errorlevel% EQU 0 SET win_vista=1

FOR /F "tokens=*" %%a in ('VER') DO SET winver=%%a

ECHO  Please Wait .....                win_vista   = %win_vista%
ECHO  Vista requires to turn User Account Control OFF
ECHO.
ECHO %winver%

SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

CD %WinDir%\system32

set drlist=
set drfat=
set drfat32=
set drntfs=
SET usbdrive=
set vdrlist=

:: ECHO fsutil DriveList = 
fsutil fsinfo drives

:: Vista has a Space Separated DriveList whereas XP has a NUL Character as Separator - It Looks the Same on Screen

IF %win_vista% EQU 0 (
  FOR /F "tokens=*" %%a in ('fsutil fsinfo drives ^| FIND /V ""') DO (
    set dr=%%a
    SET dr=!dr:~-3,3!
    SET cdr=!dr:~0,1!
    IF !cdr! GTR B (
      call set drlist=%%drlist%% %%dr:~0,2%%
      FOR /F "tokens=1 delims= " %%P IN ('fsutil fsinfo volumeinfo !dr! ^| FIND "FAT" ^| FIND /V "FAT32"') DO (
        SET vname=%%P
        SET vname=!vname:~0,1!
        IF !vname! NEQ V call set drfat=%%drfat%% %%dr:~0,2%%
      )
      FOR /F "tokens=1 delims= " %%P IN ('fsutil fsinfo volumeinfo !dr! ^| FIND "FAT32"') DO (
        SET vname=%%P
        SET vname=!vname:~0,1!
        IF !vname! NEQ V call set drfat32=%%drfat32%% %%dr:~0,2%%
      )
      FOR /F "tokens=1 delims= " %%P IN ('fsutil fsinfo volumeinfo !dr! ^| FIND "NTFS"') DO (
        SET vname=%%P
        SET vname=!vname:~0,1!
        IF !vname! NEQ V call set drntfs=%%drntfs%% %%dr:~0,2%%
      )
    )
  )
) ELSE (
  FOR /F "tokens=1,* delims= " %%a in ('fsutil fsinfo drives') DO set vdrlist=%%b
  FOR %%G IN (!vdrlist!) DO (
    SET dr=%%G
    SET dr=!dr:~-3,3!
    SET cdr=!dr:~0,1!
    IF !cdr! GTR B (
      call set drlist=%%drlist%% %%dr:~0,2%%
      FOR /F "tokens=1 delims= " %%P IN ('fsutil fsinfo volumeinfo !dr! ^| FIND "FAT" ^| FIND /V "FAT32"') DO (
        SET vname=%%P
        SET vname=!vname:~0,1!
        IF !vname! NEQ V call set drfat=%%drfat%% %%dr:~0,2%%
      )
      FOR /F "tokens=1 delims= " %%P IN ('fsutil fsinfo volumeinfo !dr! ^| FIND "FAT32"') DO (
        SET vname=%%P
        SET vname=!vname:~0,1!
        IF !vname! NEQ V call set drfat32=%%drfat32%% %%dr:~0,2%%
      )
      FOR /F "tokens=1 delims= " %%P IN ('fsutil fsinfo volumeinfo !dr! ^| FIND "NTFS"') DO (
        SET vname=%%P
        SET vname=!vname:~0,1!
        IF !vname! NEQ V call set drntfs=%%drntfs%% %%dr:~0,2%%
      )
    )
  )
)

echo.
echo  DriveList =%drlist%
echo.
ECHO  Drive FAT  =%drfat%
ECHO  Drive FAT32=%drfat32%
ECHO  Drive NTFS =%drntfs%
echo.

FOR %%a in (%drlist%) DO fsutil fsinfo drivetype %%a

:_end_quit
ECHO.
ECHO  End Program  -  DriveList_XV.CMD - Date = %DATE% %TIME:~0,8%
PAUSE
EXIT
