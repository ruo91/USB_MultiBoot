:: ==========================================================================================================================
:: ====================================== USB_MultiBoot_10.cmd ==============================================================
:: ==========================================================================================================================
TITLE USB_MultiBoot_10.cmd - INSTALL XP From USB
@ECHO OFF
CLS

IF EXIST usb_log.txt (del usb_log.txt)

:: Check Windows version
IF NOT "%OS%"=="Windows_NT"  (
  ECHO.
  ECHO ***** ONLY for Windows XP OR Windows 2003 *****
  ECHO.
  ECHO >> usb_log.txt ***** ONLY for Windows XP OR Windows 2003 *****
  GOTO _end_tee
)

set win_vista=0
:: Vista checks ::::::::::::
VER | find "6.0." > nul
IF %errorlevel% EQU 0 SET win_vista=1

IF NOT EXIST makebt\TEE.BAT (
  ECHO.
  ECHO  ***** ERROR - File makebt\TEE.BAT is Missing *****
  ECHO.
  GOTO _end_tee
)

SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

(
  ECHO.
  ECHO  Program - USB_MultiBoot_10.cmd - 06 June 2008 - Date = %DATE% %TIME:~0,8%
  ECHO.
  ECHO.
  ECHO  Prepares MultiBoot USB-Drive provided with Windows XP Setup LocalSource 
  ECHO  지원하는 부팅종류: MS-DOS  BartPE  WinPE 2.0 and Setup Windows XP
  ECHO.
  ECHO  GRUB4DOS로 가능한 부팅: DOS FLOPPY IMAGES + Linux + Vista Setup + SYSLINUX Menu
  ECHO.
  ECHO  *** 시작하기전에 : *** 되도록이면 빠른 속도의 USB메모리를 사용해주세요.
  ECHO  비스타유저는 UAC를 꼭 끄세요 - XP에서의 작업이 3배 빠릅니다.
  ECHO  외장하드 이용자분들은 1900MB의 파티션을 디스크 앞부분에 따로 만들어야 합니다.
  ECHO.
) | makebt\tee.bat -a usb_log.txt

PAUSE

IF NOT EXIST X_CONTENT\usbflash CALL :_ERROR1 X_CONTENT\usbflash
IF NOT EXIST MULTI_CONTENT\usbflash CALL :_ERROR1 MULTI_CONTENT\usbflash
IF NOT EXIST MULTI_CONTENT\usbmulti CALL :_ERROR1 MULTI_CONTENT\usbmulti
IF NOT EXIST b_ini\XP_Setup_boot.ini CALL :_ERROR1 b_ini\XP_Setup_boot.ini
IF NOT EXIST w_sif\winnt.sif CALL :_ERROR1 w_sif\winnt.sif
IF NOT EXIST w_sif\Attended_winnt.sif CALL :_ERROR1 w_sif\Attended_winnt.sif
IF NOT EXIST $OEM$_UserXP\nul CALL :_ERROR1 $OEM$_UserXP
IF NOT EXIST $OEM$_X\nul CALL :_ERROR1 $OEM$_X

IF NOT EXIST makebt\BootSect.exe CALL :_ERROR1 makebt\BootSect.exe
IF NOT EXIST makebt\binifix4.cmd CALL :_ERROR1 makebt\binifix4.cmd
IF NOT EXIST makebt\Fedit.exe CALL :_ERROR1 makebt\Fedit.exe
IF NOT EXIST makebt\gsar.exe CALL :_ERROR1 makebt\gsar.exe
IF NOT EXIST makebt\MakeBS3.cmd CALL :_ERROR1 makebt\MakeBS3.cmd
IF NOT EXIST makebt\dsfo.exe CALL :_ERROR1 makebt\dsfo.exe
IF NOT EXIST makebt\dsfi.exe CALL :_ERROR1 makebt\dsfi.exe
IF NOT EXIST makebt\migrate.inf CALL :_ERROR1 makebt\migrate.inf
IF NOT EXIST makebt\mkbt.exe CALL :_ERROR1 makebt\mkbt.exe
IF NOT EXIST makebt\MkMigrateInf2.cmd CALL :_ERROR1 makebt\MkMigrateInf2.cmd
IF NOT EXIST makebt\NO_xcopy.txt CALL :_ERROR1 makebt\NO_xcopy.txt
IF NOT EXIST makebt\presetup.cmd CALL :_ERROR1 makebt\presetup.cmd
IF NOT EXIST makebt\rdummy.sy_ CALL :_ERROR1 makebt\rdummy.sy_
IF NOT EXIST makebt\ren_fold.cmd CALL :_ERROR1 makebt\ren_fold.cmd
IF NOT EXIST makebt\syslinux.exe CALL :_ERROR1 makebt\syslinux.exe
IF NOT EXIST makebt\undoren.cmd CALL :_ERROR1 makebt\undoren.cmd
IF NOT EXIST makebt\winnt_rec.sif CALL :_ERROR1 makebt\winnt_rec.sif

IF NOT EXIST makebt\BS_F16\f16btmgr.bin CALL :_ERROR1 makebt\BS_F16\f16btmgr.bin
:: IF NOT EXIST makebt\BS_F16\f16frdos.bin CALL :_ERROR1 makebt\BS_F16\f16frdos.bin
IF NOT EXIST makebt\BS_F16\f16msdos.bin CALL :_ERROR1 makebt\BS_F16\f16msdos.bin
IF NOT EXIST makebt\BS_F16\f16ntldr.bin CALL :_ERROR1 makebt\BS_F16\f16ntldr.bin

set xpsetup=Undefined
SET usernm=Unknown
set xpuser="Unknown"
SET user_vbs=Cancel


IF EXIST usb_multi.ini (
  SET cpyflag=0
  FOR /F "tokens=1,2* delims==" %%G IN (usb_multi.ini) DO (
    SET FTAG=%%G
    IF "!FTAG!"=="[USB_MULTIBOOT]" ( 
      SET cpyflag=1
    ) ELSE (
      IF "!cpyflag!"=="1" (

        IF "!FTAG!"=="USB_TYPE" (
          IF "%%H" == "USB-Harddisk" (
            set usb_type=USB-Harddisk
          ) ELSE (
            set usb_type=USB-stick
          )
        )

        IF "!FTAG!"=="XP_SOURCE" (
          SET xpsource=
          set amd_64=0
          IF EXIST %%H\I386\DOSNET.INF (
            SET xpsource=%%H
          )
          IF EXIST %%H\AMD64\DOSNET.INF (
              SET xpsource=%%H
              set amd_64=1
          )
          ECHO %%H|FIND " ">nul
          IF "!ERRORLEVEL!"=="0" SET xpsource=
        )

        IF "!FTAG!"=="USB_CONTENT" (
          IF EXIST %%H\usbflash (
            SET usbconfg=%%H
          ) ELSE (
            SET usbconfg=X_CONTENT
          )
          ECHO %%H|FIND " ">nul
          IF "!ERRORLEVEL!"=="0" SET usbconfg=X_CONTENT
        )

        IF "!FTAG!"=="BARTPE_SOURCE" (
          IF EXIST %%H\I386\WinSxS\nul (
            SET bartpe_dir=%%H
          ) ELSE (
            SET bartpe_dir=
          )
          ECHO %%H|FIND " ">nul
          IF "!ERRORLEVEL!"=="0" SET bartpe_dir=
        )

        IF "!FTAG!"=="VISTA_SOURCE" (
          IF EXIST %%H\BOOTMGR (
            set vista_dir=%%H
          ) ELSE (
            SET vista_dir=
          )
          ECHO %%H|FIND " ">nul
          IF "!ERRORLEVEL!"=="0" SET vista_dir=
        )

        IF "!FTAG!"=="BOOT_INI" (
          SET bfile=%%H
          IF EXIST !bfile! (
            FIND "[Boot Loader]" !bfile! > nul
            IF "%ERRORLEVEL%"=="0" (
              SET btini=%%H
            )
          ) ELSE (
            set btini=b_ini\XP_Setup_boot.ini
          )
        )

        IF "!FTAG!"=="WINNT_SIF" (
          SET wfile=%%H
          IF EXIST !wfile! (
            FIND "[Data]" !wfile! > nul
            IF "%ERRORLEVEL%"=="0" (
              SET wtsif=%%H
            )
          ) ELSE (
            SET wtsif=w_sif\winnt.sif
          )
        )

        IF "!FTAG!"=="OEMD_FOL" (
          IF EXIST %%H\nul (
            SET oemd_dir=%%H
          ) ELSE (
            set oemd_dir=$OEM$_UserXP
          )
          ECHO %%H|FIND " ">nul
          IF "!ERRORLEVEL!"=="0" set oemd_dir=$OEM$_UserXP
        )

        IF "!FTAG!"=="LANG_W98" (
          IF "%%H" == "YES" (
            set lang_w98=YES
          ) ELSE (
            set lang_w98=NO
          )
        )

        IF "!FTAG!"=="LOG_TYPE" (
          IF "%%H" == "Extended" (
            set logtype=Extended
          ) ELSE (
            set logtype=Simple
          )
        )

        IF "!FTAG!"=="SYSLIN" (
          IF "%%H" == "YES" (
            set syslin=YES
          ) ELSE (
            set syslin=NO
          )
        )

        IF "!FTAG!"=="RECCON" (
          IF "%%H" == "YES" (
            set rec_con=YES
          ) ELSE (
            set rec_con=NO
          )
        )

        IF "!FTAG!"=="XPSETUP_TYPE" (
          set xpsetup=%%H
        )

        IF "!FTAG!"=="USER_NAME" (
          set usernm=%%H
          set xpuser="!usernm!"
          SET user_vbs=Cancel
        )

      )
    )
  )
) ELSE (
  set usb_type=USB-stick
  set xpsource=
  set amd_64=0
  set usbconfg=X_CONTENT
  set bartpe_dir=
  set vista_dir=
  set btini=b_ini\XP_Setup_boot.ini
  set wtsif=w_sif\winnt.sif
  set oemd_dir=$OEM$_UserXP
  set lang_w98=NO
  set logtype=Simple
  set syslin=NO
  set rec_con=NO
  set xpsetup=Undefined
  SET usernm=Unknown
  set xpuser="Unknown"
  set useradd="Unknown"
  SET user_out=Unknown
  SET user_vbs=Cancel
  SET /A count=0
  IF EXIST !oemd_dir!\useraccounts.cmd (
    FOR /F "tokens=1,2*" %%G IN (!oemd_dir!\useraccounts.cmd) DO (
      IF "%%H" == "user" (
        SET /A count=!count! + 1
        IF "!count!"=="1" SET useradd=%%I
      )
    )
    IF EXIST u_script\get_user.vbs (
      FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\get_user.vbs !useradd!') DO SET user_out=%%A
      SET usernm=!user_out!
      SET xpuser="!user_out!"
    )
  )
)

set usbdrive=
set _mypath=%~dp0
set _fselpath=%~p0
set drlist=

:: useradd="First User" password /add  OR  User /add  
:: get_user.vbs takes double quoted "First User" or simple User as Argument, thus removing password /add


:_format_menu
echo.
echo  Format USB-Drive with FAT or NTFS - FAT32 is very SLOW for Install of XP
echo.
echo     P) PeToUSB - FAT Format - 2 GB가 최대
echo.
ECHO        To Format USB-Drive  : Enable Disk Format with LBA FAT16X
echo        Do NOT Select here FileCopy of BartPE
echo        FAT Format Supports Direct Booting with MS-DOS using MULTI_CONTENT
echo        Install of XP from USB in 30 minutes - Buffalo FireStix 2 GB
echo.
echo.    H) HP USB Disk Storage Format Tool V2.0.6 - NTFS Format - use X_CONTENT
echo.
echo        NTFS Format Supports DOS Boot Floppy Images via GRUB4DOS Menu
echo        Install of XP from USB in 16 minutes - Corsair Flash Voyager 4 GB
echo.
echo        Do NOT use HP Tool for USB-Harddisks having more than 1 Partition
echo        WARNING -  HP Tool Formats whole Disk - Second Partition is Lost
echo.
echo.
echo     N) 포맷안함 - Use USB-Drive with FAT or NTFS Format by Windows XP
echo        Or Update Existing Bootable USB-Drive with NTLDR Bootsector
echo.
ECHO  Adding BartPE to USB-Drive is Possible via Next Menu
echo.

set _ok=
set /p _ok= Enter your choice: 
if /I "%_ok%" == "p" goto _getpe
if /I "%_ok%" == "h" goto _gethp
if /I "%_ok%" == "n" goto _main
ECHO.
ECHO ***** 메뉴에 없음 - 잘못된 선택 - 다시 해보세요 *****
ECHO.
pause
goto :_format_menu

:_getpe
IF EXIST PeToUSB.exe ( 
   PeToUSB.exe
   ECHO >> usb_log.txt PeToUSB.exe was launched to FORMAT USB-Drive
   ECHO.>> usb_log.txt
)
goto :_main

:_gethp
IF EXIST HPUSBFW.EXE ( 
   HPUSBFW.EXE
   ECHO >> usb_log.txt HPUSBFW.EXE was launched to FORMAT USB-Drive
   ECHO.>> usb_log.txt
)
goto :_main

:_main

echo  XP 설치 소스를 선택하고 USB-Drive 선택, 그리고 3번작업을 합니다.
echo.
echo     0) Drive 타입 변경, USB스틱 OR USB외장하드, 현재는 [%usb_type%]
echo.
echo     1) XP 설치 소스 경로 = [%xpsource%]
echo.
echo     2) USB-Drive 경로 선택, 현재는 [%usbdrive%]     X) LANG / WIN98X 폴더 복사 [%lang_w98%]
echo.
echo     3) 작업을 시작합니다.                     F) 로그파일 작성 [%logtype%] 
echo.
echo     C) Add USB Content Source,  현재는 [%usbconfg%]
echo     P) BartPE 선택, 현재는 [%bartpe_dir%]
echo     V) Vista 설치파일 경로,   현재는 [%vista_dir%]
echo.
echo     B - boot.ini 선택 = [!btini!]
echo.
IF "%xpsource%" == "" (
echo.
echo  ****  After Selecting your XP Setup Source, Additional Options are given here
echo  ****  For Changing the Selected winnt.sif file and $OEM$ Folder
echo  ****  which contain the Editable UserData for Install of Windows XP from USB 
echo.
) ELSE (
echo     W - winnt.sif 선택 = [!wtsif!]
echo.
echo     M - $OEM$ 폴더 선택 = [%oemd_dir%]
echo.
echo     E - 사용자정보 편집 = [!xpsetup!]    사용자이름 = [!usernm!]
)
echo.
echo     Q) 끝내기    R) 복구 콘솔 [%rec_con%]      S) SYSLINUX Menu [%syslin%]
echo.                                   

:: Recovery Console only via GRUB4DOS to avoid Conflict with XP Setup - Or Use Option R from TXT Setup

set _ok=
set /p _ok= Enter your choice: 
if "%_ok%" == "0" goto _getype
if "%_ok%" == "1" goto _getsrc
if "%_ok%" == "2" goto _getusb
if "%_ok%" == "3" goto _mktemp
if /I "%_ok%" == "c" goto _getcfg
if /I "%_ok%" == "p" goto _getbpe
if /I "%_ok%" == "v" goto _getvista
if /I "%_ok%" == "b" goto _getbini
IF "%xpsource%" NEQ "" (
  if /I "%_ok%" == "w" goto _getwsif
  if /I "%_ok%" == "m" goto _getOEMD
  if /I "%_ok%" == "e" goto _getpara
)
if /I "%_ok%" == "x" goto _getlang
if /I "%_ok%" == "f" goto _getlog
if /I "%_ok%" == "r" goto _getcons
if /I "%_ok%" == "s" goto _getlinux
if /I "%_ok%" == "q" goto _end_quit
ECHO.
ECHO ***** NOT in Menu - Wrong Selection - Try Again *****
ECHO.
pause
goto :_main

:_getype
IF "%usb_type%" == "USB-stick" (
    set usb_type=USB-Harddisk
) ELSE (
    set usb_type=USB-stick
)
goto _main

:_getbini
set src_ok=
ECHO.
ECHO  Select boot.ini File
ECHO.
IF %win_vista% EQU 0 (
  IF EXIST u_script\FileSel_ini.vbs (
    FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FileSel_ini.vbs %_fselpath%') DO SET src_ok="%%A"
  ) ELSE (
    ECHO  e.g Type D:\USB_MultiBoot_10\b_ini\Multi_boot.ini
    set /p src_ok= Enter boot.ini FileName and Path: 
  )
) ELSE (
  ECHO  e.g Type D:\USB_MultiBoot_10\b_ini\Multi_boot.ini
  set /p src_ok= Enter boot.ini FileName and Path: 
)
  
IF "!src_ok!"=="" GOTO _main
IF NOT EXIST !src_ok! (
  ECHO.
  ECHO  ***** ERROR - boot.ini File does NOT Exist - Select Again *****
  ECHO.
  pause
  GOTO _main
)

FIND "[Boot Loader]" !src_ok! > nul
IF ERRORLEVEL 1 (
  ECHO.
  ECHO  ********************** [Boot Loader] Tag Missing **********************
  ECHO.
  ECHO  ***** ERROR - Selection is NOT Valid boot.ini File - Select Again *****
  ECHO.
  pause
  GOTO _main
)

SET btini=!src_ok!
goto _main



:_getwsif
set src_ok=
ECHO.
ECHO  Select winnt.sif File
ECHO.
IF %win_vista% EQU 0 (
  IF EXIST u_script\FileSel_sif.vbs (
    FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FileSel_sif.vbs %_fselpath%') DO SET src_ok="%%A"
  ) ELSE (
    ECHO  e.g Type D:\USB_MultiBoot_10\w_sif\winnt.sif
    set /p src_ok= Enter winnt.sif FileName and Path: 
  )
) ELSE (
  ECHO  e.g Type D:\USB_MultiBoot_10\w_sif\winnt.sif
  set /p src_ok= Enter winnt.sif FileName and Path: 
)

IF "!src_ok!"=="" GOTO _main
IF NOT EXIST !src_ok! (
  ECHO.
  ECHO  ***** ERROR - winnt.sif File does NOT Exist - Select Again *****
  ECHO.
  pause
  GOTO _main
)

FIND "[Data]" !src_ok! > nul
IF ERRORLEVEL 1 (
  ECHO.
  ECHO  ******************* [Data] Section MISSING *****************************
  ECHO.
  ECHO  ***** ERROR - Selection is NOT Valid winnt.sif File - Select Again *****
  ECHO.
  pause
  goto _main
) 

SET wtsif=!src_ok!
set xpsetup=Undefined

goto _getpara



:_getOEMD
set src_ok=
echo.
echo  Please Select your $OEM$ Folder e.g. $OEM$_UserXP 

IF EXIST u_script\FolderSel.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSel.vbs') DO SET src_ok=%%A
) ELSE (
  ECHO  e.g Type D:\USB_MultiBoot_10\$OEM$_UserXP
  set /p src_ok= Enter $OEM$ Folder Path: 
)
ECHO.

IF "%src_ok%" == "" goto _main

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

if exist %src_ok%\nul (
  SET oemd_dir=%src_ok%
) else (
  echo.
  echo  SELECTED %src_ok%
  echo  ***** Error: Selected Folder does not Exist - Select Again *****
  echo.
  pause
  goto _main
)

set xpsetup=Undefined
SET usernm=Unknown
set xpuser="Unknown"
set useradd="Unknown"
SET user_out=Unknown
SET user_vbs=Cancel
SET /A count=0
IF EXIST !oemd_dir!\useraccounts.cmd (
  FOR /F "tokens=1,2*" %%G IN (!oemd_dir!\useraccounts.cmd) DO (
    IF "%%H" == "user" (
      SET /A count=!count! + 1
      IF "!count!"=="1" SET useradd=%%I
    )
  )
  IF EXIST u_script\get_user.vbs (
    FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\get_user.vbs !useradd!') DO SET user_out=%%A
    SET usernm=!user_out!
    SET xpuser="!user_out!"
  )
)

goto _getpara



:_getpara

IF "%wtsif%" NEQ "w_sif\Current_winnt.sif" (
  copy /y %wtsif% w_sif\Current_winnt.sif
) ELSE (
  IF NOT EXIST w_sif\Current_winnt.sif copy /y w_sif\winnt.sif w_sif\Current_winnt.sif
)

SET wtsif=w_sif\Current_winnt.sif

IF EXIST u_script\RW_SIF.VBS (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\RW_SIF.VBS %wtsif% !xpuser!') DO SET user_vbs=%%A
)

IF "!user_vbs!"=="Cancel" goto _main

IF "!user_vbs!"=="None" (
  set xpsetup=Semi_Unattended
  SET usernm=None
  set xpuser="None"
) ELSE (
  set xpsetup=Unattended
  SET usernm=!user_vbs!
  set xpuser="!usernm!"
)

IF EXIST usb_multi.ini (
  makebt\fedit -f usb_multi.ini -rem -l:o USER_NAME -s USB_MULTIBOOT
  makebt\fedit -f usb_multi.ini -add -create -l "USER_NAME=%usernm%" -s USB_MULTIBOOT
  makebt\fedit -f usb_multi.ini -rem -l:o XPSETUP_TYPE -s USB_MULTIBOOT
  makebt\fedit -f usb_multi.ini -add -create -l "XPSETUP_TYPE=%xpsetup%" -s USB_MULTIBOOT
)

goto _main


:_getlang
IF "%lang_w98%" == "YES" (
   set lang_w98=NO
) ELSE (
   set lang_w98=YES
)
goto _main


:_getlog
IF "%logtype%" == "Simple" (
   set logtype=Extended
) ELSE (
   set logtype=Simple
)
goto _main


:_getcons
IF "%rec_con%" == "YES" (
   set rec_con=NO
) ELSE (
   set rec_con=YES
)
goto _main


:_getlinux
IF "%syslin%"=="YES" (
   set syslin=NO
) ELSE (
  if exist %usbconfg%\usbflash (
    if exist %usbconfg%\usbmulti (
      set syslin=YES
    ) else (
      echo.
      echo  SYSLINUX Menu NOT Available - Select First USB MULTI_CONTENT Source
      echo  Error: USB Multi Content Source TagFile usbmulti NOT FOUND
      echo.
      pause
      goto _main
    )
  ) else (
    echo.
    echo  SYSLINUX Menu NOT Available - Select First USB MULTI_CONTENT Source
    echo  Error: USB Content Source TagFile usbflash NOT FOUND
    echo.
    pause
    goto _main
  )
)
goto _main


:_getsrc
set src_ok=
SET xpdir=\I386
echo.
echo  Please Select your XP Setup Source Folder containing I386 Folder

IF EXIST u_script\FolderSel.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSel.vbs') DO SET src_ok=%%A
) ELSE (
  ECHO  e.g if you have D:\XPSOURCE\I386 type D:\XPSOURCE
  set /p src_ok= Enter XP Source path: 
)

IF "%src_ok%" == "" goto _main

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

ECHO %src_ok%|FIND "I386"
IF "%ERRORLEVEL%"=="0" (
  echo.
  echo  ***** Error: Selected Path does Contain I386 and is Invalid *****
  echo.
  echo     Solution: Select your XPSOURCE Folder and NOT I386 Folder
  echo.
  pause
  goto _main
)

ECHO %src_ok%|FIND "AMD64"
IF "%ERRORLEVEL%"=="0" (
  echo.
  echo  ***** Error: Selected Path does Contain AMD64 and is Invalid *****
  echo.
  echo     Solution: Select your XPSOURCE Folder and NOT AMD64 Folder
  echo.
  pause
  goto _main
)

if exist %src_ok%\I386\DOSNET.INF (
  SET xpsource=%src_ok%
  set amd_64=0
  SET xpdir=\I386
) else (
  if exist %src_ok%\AMD64\DOSNET.INF (
    SET xpsource=%src_ok%
    set amd_64=1
    SET xpdir=\amd64
  ) else (
    echo.
    echo  SELECTED %src_ok%
    echo  Error: DOSNET.INF NOT Found in I386 Or AMD64 Folder
    echo.
    pause
    goto _main
  )
)

set Confirm=y
if exist !xpsource!!xpdir!\winnt.sif (
  ECHO.
  ECHO  Existing File winnt.sif in XPSOURCE is Detected with Setup Paramaters
  IF EXIST u_script\Msg_Exist_winnt_sif.vbs (
     FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_Exist_winnt_sif.vbs') DO SET Conf=%%A
     IF "!Conf!"=="6" SET Confirm=y
     IF "!Conf!"=="7" SET Confirm=n
  ) ELSE (
    ECHO.
    SET /P Confirm= Copy winnt.sif from XPSOURCE and Use Empty $OEM$_X Folder?  Enter y/n: 
  )
  IF /I !Confirm!.==y. (
    SET wtsif=!xpsource!!xpdir!\winnt.sif
    set oemd_dir=$OEM$_X
  ) ELSE (
    set wtsif=w_sif\winnt.sif
  )
)
 
set Confirm=n
if exist !xpsource!\$OEM$\nul (
  ECHO.
  ECHO  Existing $OEM$ Folder in XPSOURCE Detected - Registry Tweaks and UserAccounts
  IF EXIST u_script\Msg_Exist_OEMD_FOLDER.vbs (
     FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_Exist_OEMD_FOLDER.vbs') DO SET Conf=%%A
     IF "!Conf!"=="6" SET Confirm=y
  ) ELSE (
    ECHO.
    SET /P Confirm= Copy $OEM$ Folder from XPSOURCE ?  Please enter y/n: 
  )
  IF /I !Confirm!.==y. SET oemd_dir=!xpsource!\$OEM$
) 

set xpsetup=Undefined
SET usernm=Unknown
set xpuser="Unknown"
set useradd="Unknown"
SET user_out=Unknown
SET user_vbs=Cancel
SET /A count=0
IF EXIST !oemd_dir!\useraccounts.cmd (
  FOR /F "tokens=1,2*" %%G IN (!oemd_dir!\useraccounts.cmd) DO (
    IF "%%H" == "user" (
      SET /A count=!count! + 1
      IF "!count!"=="1" SET useradd=%%I
    )
  )
  IF EXIST u_script\get_user.vbs (
    FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\get_user.vbs !useradd!') DO SET user_out=%%A
    SET usernm=!user_out!
    SET xpuser="!user_out!"
  )
)

goto _getpara



:_getcfg
set src_ok=
echo.
echo  Please Select your USB Content Source Folder e.g. MULTI_CONTENT 

IF EXIST u_script\FolderSel.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSel.vbs') DO SET src_ok=%%A
) ELSE (
  ECHO  e.g Type D:\USB_MultiBoot_10\MULTI_CONTENT
  set /p src_ok= Enter USB Content Source Path: 
)
ECHO.

IF "%src_ok%" == "" goto _main

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

if exist %src_ok%\usbflash (
  SET usbconfg=%src_ok%
) else (
  echo.
  echo  SELECTED %src_ok%
  echo  Error: USB Content Source TagFile usbflash NOT FOUND
  echo.
  pause
  goto _main
)

if NOT exist %usbconfg%\usbmulti set syslin=NO

goto _main


:_getbpe
set src_ok=
SET bartpe_dir=
echo.
echo  Please Select your BartPe Source Folder 

IF EXIST u_script\FolderSel.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSel.vbs') DO SET src_ok=%%A
) ELSE (
  set /p src_ok= Enter BartPE Source Path: 
)
ECHO.

IF "%src_ok%" == "" goto _main

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


if exist %src_ok%\I386\WinSxS\nul (
  SET bartpe_dir=%src_ok%
) else (
        echo.
        echo  SELECTED %src_ok%
        echo  Error: Selected Folder does not contain BartPE Source Files
        echo.
        echo  Folder I386\WinSxS was NOT Found
        echo.
	pause
)
goto _main


:_getvista
set src_ok=
SET vista_dir=
echo.
echo  Please Select your Vista Source Folder 

IF EXIST u_script\FolderSel.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSel.vbs') DO SET src_ok=%%A
) ELSE (
  set /p src_ok= Enter Vista Source Path: 
)
ECHO.

IF "%src_ok%" == "" goto _main

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

IF EXIST %src_ok%\BOOTMGR (
  SET vista_dir=%src_ok%
) ELSE (
  echo.
  echo  SELECTED %src_ok%
  echo  WARNING - BOOTMGR was NOT Found in Root of Selected VISTA Source
  echo.
  set Confirm=n
  IF EXIST u_script\Msg_BOOTMGR.vbs (
     FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_BOOTMGR.vbs') DO SET Conf=%%A
     IF "!Conf!"=="6" SET Confirm=y
  ) ELSE (
    SET /P Confirm= BOOTMGR was NOT Found in Root - CONTINUE ?  Please enter y/n: 
  )
  IF /I !Confirm!.==n. GOTO _main
  SET vista_dir=%src_ok%
)
goto _main


:_getusb
set _ok=
set drlist=
SET usbdrive=

::  Only FAT use  FOR /F "tokens=*" %%G IN ('fsutil fsinfo volumeinfo !dr! ^| FIND "FAT" ^| FIND /V "FAT32"') DO ( 

IF %win_vista% EQU 0 (
  FOR /F "tokens=*" %%a in ('fsutil fsinfo drives ^| FIND /V ""') DO (
    set dr=%%a
    SET dr=!dr:~-3,3!
    SET cdr=!dr:~0,1!
    IF !cdr! GTR C (
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
    IF !cdr! GTR C (
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
echo  Select Target USB-Drive from DriveList
ECHO.

IF EXIST u_script\FolderSel.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSel.vbs') DO SET _ok=%%A
  IF "!_ok!"=="" goto _main
  set _ok=!_ok:~0,1!
) ELSE (
  set /p _ok= Enter Target USB-Drive Letter: 
  IF "!_ok!"=="" (
    echo.
    echo  ***** Drive is NOT Valid *****
    echo.
    pause
    goto _main
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

IF "!_ok!"=="C" (
  echo.
  echo  ***** C-Drive is NOT Allowed - Selection NOT Valid *****
  echo.
  pause
  goto _main
)

FOR %%i IN (%drlist%) DO IF "%%i" == "!_ok!:" SET usbdrive=!_ok!:

if "%usbdrive%" == "" ( 
        echo.
        echo  ***** !_ok!: has NOT FAT FAT32 or NTFS Format and is NOT Valid *****
        echo.
	pause
	goto _main
)

SET Conf=0
IF EXIST u_script\MSg_DriveReady.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\MSg_DriveReady.vbs %usbdrive%') DO SET Conf=%%A
  IF "!Conf!"=="0" (
    ECHO.
    ECHO  ***** Drive NOT Ready - First Format Disk with PeToUSB.exe *****
    ECHO.
    PAUSE
    GOTO _main
  )
)

if EXIST %usbdrive%\$WIN_NT$.~LS\I386\nul (
        echo.
	echo  ***** WARNING Existing Folder $WIN_NT$.~LS on USB-Drive Detected   *****
        echo.
        echo.>> usb_log.txt
	echo >> usb_log.txt  ***** WARNING Existing Folder $WIN_NT$.~LS on USB-Drive Detected   *****
        echo >> usb_log.txt  ***** Create New XP Source Or Update Existing Folders on USB-Drive *****
        echo.>> usb_log.txt
	pause
)
goto _main

:_mktemp

IF "%xpsource%" == "" (
        echo.
        echo  ***** Please give first valid XP Source Path *****
        echo.
	pause
	goto _main
)

IF "%usbconfg%" == "" (
        echo.
        echo  ***** Please give first valid USB Content Source Path *****
        echo.
	pause
	goto _main
)

IF "%usbdrive%" == "" (
        echo.
        echo  ***** Please give first valid Target USB-Drive Letter *****
        echo.
	pause
	goto _main
)

IF "%usbdrive%" == "!usbconfg:~0,2!" (
        echo.
        echo  ***** ERROR - Target and Source are Equal Drives - Make Changes *****
        echo.
	pause
	goto _main
)

IF "%usbdrive%" == "!xpsource:~0,2!" (
        echo.
        echo  ***** ERROR - Target and Source are Equal Drives - Make Changes *****
        echo.
	pause
	goto _main
)

SET Conf=0
IF EXIST u_script\MSg_DriveReady.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\MSg_DriveReady.vbs %usbdrive%') DO SET Conf=%%A
  IF "!Conf!"=="0" (
    ECHO.
    ECHO  ***** Drive NOT Ready - First Format Disk with PeToUSB.exe *****
    ECHO.
    PAUSE
    GOTO _main
  )
)

::  Msg_DiskSize.vbs  Msg_FreeSpace.vbs  FolderSize_U.vbs to determine Overflow
SET u_mb=50
IF EXIST u_script\Msg_DiskSize.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_DiskSize.vbs %usbdrive%') DO SET Conf=%%A
  SET /A u_mb=!Conf:~0,-3! - 50
)

ECHO.
ECHO  USB-Drive Size = %u_mb% MB + 50 MB Reserved    Please Wait ....  
ECHO.
ECHO  Measuring FREESPACE and Size of XP Source and Other Source Folders 
ECHO.

SET u_free=51
IF EXIST u_script\Msg_FreeSpace.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_FreeSpace.vbs %usbdrive%') DO SET Conf=%%A
  SET /A u_free=!Conf:~0,-3! - 50
)

:: cmpnents + $WIN_NT$.~BT = 35 MB, Adding  I386 + AMD64 + $OEM$ + OEM is included in u_xpfolder size
:: reduction of LANG and WIN98X is taken into account by subtracting 135 MB

SET /A u_xpfolder=35
IF EXIST u_script\FolderSize_U.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSize_U.vbs %xpsource%\I386') DO SET Conf=%%A
  IF !Conf! GTR 1000000 (
    SET /A u_xpfolder=!u_xpfolder! + !Conf:~0,-6!
  ) ELSE (
    SET u_xpfolder=!u_xpfolder! + 1
  )

  IF EXIST %xpsource%\AMD64\nul (
    FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSize_U.vbs %xpsource%\AMD64') DO SET Conf=%%A
    IF !Conf! GTR 1000000 (
      SET /A u_xpfolder=!u_xpfolder! + !Conf:~0,-6!
    )
  )

  IF EXIST %oemd_dir%\nul (
    FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSize_U.vbs %oemd_dir%') DO SET Conf=%%A
    IF !Conf! GTR 1000000 (
      SET /A u_xpfolder=!u_xpfolder! + !Conf:~0,-6!
    )
  )

  IF EXIST %xpsource%\OEM\bin\DPsFnshr.7z (
    FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSize_U.vbs %xpsource%\OEM') DO SET Conf=%%A
    IF !Conf! GTR 1000000 (
      SET /A u_xpfolder=!u_xpfolder! + !Conf:~0,-6!
    )
  )

  IF "%lang_w98%" == "NO" (
    IF EXIST %xpsource%\I386\LANG\nul (
      SET /A u_xpfolder=!u_xpfolder! - 135
    )
  )

  IF !u_xpfolder! LSS 0 (
    SET /A u_xpfolder=1
  )
)


SET u_con=1
IF EXIST u_script\FolderSize_U.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSize_U.vbs %usbconfg%') DO SET Conf=%%A
  IF !Conf! GTR 1000000 (
    SET /A u_con=!Conf:~0,-6!
  ) ELSE (
    SET u_con=1
  )
)

SET u_bart=0
IF "%bartpe_dir%"=="" (
  SET u_bart=0
) ELSE (
  IF EXIST u_script\FolderSize_U.vbs (
    FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSize_U.vbs %bartpe_dir%') DO SET Conf=%%A
    IF !Conf! GTR 1000000 (
      SET /A u_bart=!Conf:~0,-6!
    ) ELSE (
      SET u_bart=0
    )
  )
)

SET u_vista=0
IF "%vista_dir%"=="" (
  SET u_vista=0
) ELSE (
  IF EXIST u_script\FolderSize_U.vbs (
    FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSize_U.vbs %vista_dir%') DO SET Conf=%%A
    IF !Conf! GTR 1000000 (
      SET /A u_vista=!Conf:~0,-6!
    ) ELSE (
      SET u_vista=0
    )
  )
)


set Confirm=n
IF !u_mb! GTR 20000 (
  IF EXIST u_script\Msg_DiskSize20.vbs (
     FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_DiskSize20.vbs') DO SET Conf=%%A
     IF "!Conf!"=="6" SET Confirm=y
  ) ELSE (
    SET /P Confirm= WARNING - DiskSize Over 20 GB - CONTINUE ?  Please enter y/n: 
  )
  IF /I !Confirm!.==n. GOTO _main
) 

set Confirm=n
SET /A u_used=!u_mb!-!u_free!
IF !u_used! GTR 5000 (
  ECHO  USB-Drive - 50 = %u_mb% MB  FREE = !u_free! MB  USED = !u_used! MB
  IF EXIST u_script\Msg_Content.vbs (
     FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_Content.vbs') DO SET Conf=%%A
     IF "!Conf!"=="6" SET Confirm=y
  ) ELSE (
    ECHO.
    ECHO  ***** WARNING - Target Drive - Used Space is More than 5 GB ***** 
    ECHO.
    SET /P Confirm= CONTINUE ?  Please enter y/n: 
  )
  IF /I !Confirm!.==n. GOTO _main
)

IF %u_xpfolder% GTR %u_mb% (
  ECHO.
  ECHO  USB-Drive - 50 = %u_mb% MB  XP-Source = %u_xpfolder% MB
  ECHO.
  ECHO  ***** USB-Drive Size TOO SMALL to Copy XP Source - WARNING *****
  ECHO.
  PAUSE
)

IF %u_con% GTR %u_mb% (
  ECHO.
  ECHO  USB-Drive - 50 = %u_mb% MB  USB CONTENT SOURCE = %u_con% MB
  ECHO.
  ECHO  ***** USB-Drive Size TOO SMALL for USB Content Source - Make Changes *****
  ECHO.
  PAUSE
  GOTO _main
)

IF %u_bart% GTR %u_mb% (
  ECHO.
  ECHO  USB-Drive - 50 = %u_mb% MB  BartPE SOURCE = %u_bart% MB
  ECHO.
  ECHO  ***** USB-Drive Size TOO SMALL for BartPE SOURCE - Make Changes *****
  ECHO.
  PAUSE
  GOTO _main
)

IF %u_vista% GTR %u_mb% (
  ECHO.
  ECHO  USB-Drive - 50 = %u_mb% MB  VISTA SOURCE = %u_vista% MB
  ECHO.
  ECHO  ***** USB-Drive Size TOO SMALL for VISTA SOURCE - Make Changes *****
  ECHO.
  PAUSE
  GOTO _main
)

SET /A UC_ADD=%u_con% + %u_bart% + %u_vista%

IF !UC_ADD! GTR %u_mb% (
  ECHO.
  ECHO  USB-Drive - 50 = %u_mb% MB  ADD SOURCES = !UC_ADD! MB
  ECHO.
  ECHO  ***** USB-Drive Size TOO SMALL for ADD SOURCES - Make Changes *****
  ECHO.
  PAUSE
  GOTO _main
)


:: ECHO.
:: makebt\DIRUSE /m /q:%u_mb% %usbconfg%
:: IF ERRORLEVEL 1 (
::   ECHO.
::   ECHO  ***** USB-Drive Size TOO SMALL for USB Content Source - Make Changes *****
::   ECHO.
::   PAUSE
::   GOTO _main
:: )
:: ECHO.

:: Last Check for Drive with FAT FAT32 or NTFS Format NOT Being C-Drive

set drlist=

IF %win_vista% EQU 0 (
  FOR /F "tokens=*" %%a in ('fsutil fsinfo drives ^| FIND /V ""') DO (
    set dr=%%a
    SET dr=!dr:~-3,3!
    SET cdr=!dr:~0,1!
    IF !cdr! GTR C (
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
    IF !cdr! GTR C (
      FOR /F "tokens=1 delims= " %%G IN ('fsutil fsinfo volumeinfo !dr! ^| FINDSTR "FAT NTFS"') DO (
        SET vname=%%G
        SET vname=!vname:~0,1!
        IF !vname! NEQ V call set drlist=%%drlist%% %%dr:~0,2%%
      )
    )
  )
)

:: pause

FOR %%i IN (%drlist%) DO IF "%%i" == "%usbdrive%" goto _mkmulti
ECHO.
ECHO  ***** ERROR - Drive has NOT FAT FAT32 OR NTFS Format OR is C-Drive ******
ECHO.
pause
goto _main

:: ==========================================================================================================================
:: ================= PART 1 - Preparing Temporary Folder usb_xpbt  ==========================================================
:: ==========================================================================================================================

:_mkmulti

ECHO  =============================================================================
ECHO  ================= PART 1 - Preparing Temporary Folder usb_xpbt ==============
ECHO  =============================================================================
ECHO >> usb_log.txt =============================================================================
ECHO >> usb_log.txt ================= PART 1 - Preparing Temporary Folder usb_xpbt ==============
ECHO >> usb_log.txt =============================================================================

:: pause
:: Save Settings in usb_multi.ini

IF EXIST usb_multi.ini (del usb_multi.ini)

ECHO [USB_MULTIBOOT]>usb_multi.ini
ECHO USB_TYPE=%usb_type%>>usb_multi.ini
ECHO XP_SOURCE=%xpsource%>>usb_multi.ini
ECHO USB_CONTENT=%usbconfg%>>usb_multi.ini
ECHO BARTPE_SOURCE=%bartpe_dir%>>usb_multi.ini
ECHO VISTA_SOURCE=%vista_dir%>>usb_multi.ini
ECHO BOOT_INI=%btini%>>usb_multi.ini
ECHO WINNT_SIF=%wtsif%>>usb_multi.ini
ECHO OEMD_FOL=%oemd_dir%>>usb_multi.ini
ECHO LANG_W98=%lang_w98%>>usb_multi.ini
ECHO LOG_TYPE=%logtype%>>usb_multi.ini
ECHO SYSLIN=%syslin%>>usb_multi.ini
ECHO RECCON=%rec_con%>>usb_multi.ini
ECHO XPSETUP_TYPE=%xpsetup%>>usb_multi.ini
ECHO USER_NAME=%usernm%>>usb_multi.ini

SET FileSys=NTFS
IF EXIST u_script\Msg_FileSys.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_FileSys.vbs %usbdrive%') DO SET FileSys=%%A
)

echo >> usb_log.txt DriveList FAT FAT32 NTFS
echo >> usb_log.txt drives   = %drlist%
echo >> usb_log.txt mkbtpath = %_mypath%
echo.>> usb_log.txt
echo >> usb_log.txt usb_type = %usb_type%
echo >> usb_log.txt usbdrive = %usbdrive%  has FileSystem = %FileSys%
echo >> usb_log.txt xpsource = %xpsource%
echo >> usb_log.txt usbconfg = %usbconfg%
echo >> usb_log.txt bartpe   = %bartpe_dir%
echo >> usb_log.txt vista    = %vista_dir%
echo.>> usb_log.txt
echo >> usb_log.txt boot_ini = %btini%
echo >> usb_log.txt winnt_sif= %wtsif%
echo >> usb_log.txt oemd_dir = %oemd_dir%
echo >> usb_log.txt lang_w98 = %lang_w98%
echo >> usb_log.txt log type = %logtype%
echo >> usb_log.txt SYSLINUX = %syslin%
echo >> usb_log.txt REC_CONS = %rec_con%
echo.>> usb_log.txt XPSETUP  = %xpsetup%
echo.>> usb_log.txt USER_NAME= %usernm%
echo.>> usb_log.txt
ECHO.>> usb_log.txt Date = !DATE! !TIME:~0,8!
ECHO.>> usb_log.txt

IF EXIST makebt\bs_temp\nul rd /S /Q makebt\bs_temp
IF NOT EXIST makebt\bs_temp\nul MD makebt\bs_temp

makebt\mkbt.exe -x -c %usbdrive% makebt\bs_temp\BS_Backup.bs

SET change_bs=0

FIND "NTLDR" makebt\bs_temp\BS_Backup.bs > nul
IF ERRORLEVEL 1 SET change_bs=1

FIND "BOOTMGR" makebt\bs_temp\BS_Backup.bs > nul
IF "!ERRORLEVEL!"== "0" SET change_bs=1

IF "!change_bs!"== "1" (
  set Confirm=y
  IF EXIST u_script\Msg_Vista.vbs (
     FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_Vista.vbs') DO SET Conf=%%A
     IF "!Conf!"=="7" SET Confirm=n
  ) ELSE (
    SET /P Confirm= Change BootSector to NTLDR Type, Continue ?  Please enter y/n: 
  )
  IF /I !Confirm!.==n. GOTO _end_quit
  ECHO  ============================================================================= 
  ECHO   NOT NTLDR Type - Vista BOOTMGR Bootsector is Converted to NTLDR BootSector
  ECHO  =============================================================================
  ECHO.
  ECHO >> usb_log.txt ============================================================================= 
  ECHO >> usb_log.txt  NOT NTLDR Type - Vista BOOTMGR Bootsector is Converted to NTLDR BootSector
  ECHO >> usb_log.txt =============================================================================
  ECHO.>> usb_log.txt
  FIND "FAT16" makebt\bs_temp\BS_Backup.bs >NUL
  IF !ERRORLEVEL!==0 (
     makebt\mkbt.exe -x makebt\BS_F16\f16ntldr.bin %usbdrive%
  ) ELSE (
    makebt\BootSect.exe /nt52 %usbdrive% /force
  )
)

ECHO  *** Make Temporary Folder usb_xpbt with Custom XP Setup BootFiles ***
ECHO.
ECHO  Parse DOSNET.INF for making Windows XP Setup Bootfolder $WIN_NT$.~BT
ECHO.
ECHO >> usb_log.txt *** Make Temporary Folder usb_xpbt with Custom XP Setup BootFiles ***
ECHO.>> usb_log.txt
ECHO >> usb_log.txt Parse DOSNET.INF for making Windows XP Setup Bootfolder $WIN_NT$.~BT
ECHO.>> usb_log.txt

IF EXIST usb_xpbt\nul rd /S /Q usb_xpbt
IF NOT EXIST usb_xpbt\nul MD usb_xpbt

:: Make Destination directories for XP Setup Bootfolder
IF NOT EXIST usb_xpbt\$WIN_NT$.~BT\nul MD usb_xpbt\$WIN_NT$.~BT
IF NOT EXIST usb_xpbt\$WIN_NT$.~BT\system32\nul MD usb_xpbt\$WIN_NT$.~BT\system32
IF NOT EXIST usb_xpbt\$WIN_NT$.~LS\nul MD usb_xpbt\$WIN_NT$.~LS
IF NOT EXIST usb_xpbt\$WIN_NT$.~LS\I386\nul MD usb_xpbt\$WIN_NT$.~LS\I386
IF NOT EXIST usb_xpbt\cmdcons\nul MD usb_xpbt\cmdcons


IF %amd_64% EQU 1 GOTO _xpbt_amd64

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
         xcopy %xpsource%\I386\!btfile! usb_xpbt\$WIN_NT$.~BT /i /k /r /y /h
      ) ELSE (
         copy /y %xpsource%\I386\%%H usb_xpbt\$WIN_NT$.~BT\%%I
      )
    ) 
  )
)

:: CmdCons Folder x86
::
ECHO  Making Recovery Console Folder cmdcons ....
ECHO.
ECHO >> usb_log.txt Making Recovery Console Folder cmdcons ....
ECHO.>> usb_log.txt

SET cpyflag=0
FOR /F "tokens=1,2* delims== " %%G IN (%xpsource%\I386\DOSNET.INF) DO (
  SET FTAG=%%G
  IF "!FTAG!"=="[CmdConsFiles]" ( 
    SET cpyflag=1
  ) ELSE (
    SET FTAG=!FTAG:~0,1!
    IF "!FTAG!"=="[" SET cpyflag=0
    IF "!cpyflag!"=="1" (
      copy /y %xpsource%\I386\%%G usb_xpbt\cmdcons
    ) 
  )
)

xcopy usb_xpbt\$WIN_NT$.~BT\*.* usb_xpbt\cmdcons\ /i /k /e /r /y /h
copy /y makebt\winnt_rec.sif usb_xpbt\cmdcons\winnt.sif

:: copy /y %xpsource%\I386\setupldr.bin usb_xpbt\CMLDR
:: Instead Launch Recovery Console via GRUB4DOS menu.lst

ECHO.
ECHO.>> usb_log.txt
ECHO  Making Recovery Console Folder cmdcons Ready
ECHO >> usb_log.txt Making Recovery Console Folder cmdcons Ready

GOTO _xpbt_ready

:: Start x64 - Parse DOSNET.INF from AMD64 Folder
:: 

:_xpbt_amd64
SET xpdir=\amd64
SET cpyflag=0
FOR /F "tokens=1,2,3* delims=, " %%G IN (%xpsource%\AMD64\DOSNET.INF) DO (
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
      SET dnum=%%G
      IF "!dnum!"=="d1" SET xpdir=\amd64
      IF "!dnum!"=="d2" SET xpdir=\I386
      IF "%%I"=="" (
         SET btfile=!btfile:~0,-1!*
         xcopy %xpsource%!xpdir!\!btfile! usb_xpbt\$WIN_NT$.~BT /i /k /r /y /h
      ) ELSE (
         copy /y %xpsource%!xpdir!\%%H usb_xpbt\$WIN_NT$.~BT\%%I
      )
    ) 
  )
)

:: For Recovery Console x64 - Replace I386 with AMD64 except for \I386\setupldr.bin

ECHO  Making x64 Recovery Console Folder cmdcons ....
ECHO.
ECHO >> usb_log.txt Making x64 Recovery Console Folder cmdcons ....
ECHO.>> usb_log.txt

SET cpyflag=0
FOR /F "tokens=1,2* delims== " %%G IN (%xpsource%\AMD64\DOSNET.INF) DO (
  SET FTAG=%%G
  IF "!FTAG!"=="[CmdConsFiles]" ( 
    SET cpyflag=1
  ) ELSE (
    SET FTAG=!FTAG:~0,1!
    IF "!FTAG!"=="[" SET cpyflag=0
    IF "!cpyflag!"=="1" (
      copy /y %xpsource%\AMD64\%%G usb_xpbt\cmdcons
    ) 
  )
)

xcopy usb_xpbt\$WIN_NT$.~BT\*.* usb_xpbt\cmdcons\ /i /k /e /r /y /h
copy /y makebt\winnt_rec.sif usb_xpbt\cmdcons\winnt.sif

:: copy /y %xpsource%\I386\setupldr.bin usb_xpbt\CMLDR
:: Instead Launch Recovery Console via GRUB4DOS menu.lst

ECHO.
ECHO.>> usb_log.txt
ECHO  Making Recovery Console Folder cmdcons Ready
ECHO >> usb_log.txt Making Recovery Console Folder cmdcons Ready


:_xpbt_ready
IF EXIST usb_xpbt\$WIN_NT$.~BT\NTLDR DEL usb_xpbt\$WIN_NT$.~BT\NTLDR
ECHO  Making Windows XP Setup Bootfolder usb_xpbt\$WIN_NT$.~BT - READY
ECHO >> usb_log.txt Making Windows XP Setup Bootfolder usb_xpbt\$WIN_NT$.~BT - READY
ECHO.>> usb_log.txt Date = !DATE! !TIME:~0,8!
ECHO.>> usb_log.txt
ECHO.
ECHO  Copying Custom files and XP Root files to Temporary Folder usb_xpbt ....
ECHO.
xcopy makebt\binifix4.cmd usb_xpbt\$WIN_NT$.~LS\I386 | makebt\tee.bat -a usb_log.txt
ECHO.>> usb_log.txt
ECHO.
xcopy makebt\migrate.inf usb_xpbt\$WIN_NT$.~BT\ /y | makebt\tee.bat -a usb_log.txt
ECHO.>> usb_log.txt
ECHO.
ECHO >> usb_log.txt Copy winnt.sif file from %wtsif% and for Attended Setup make winat.sif
copy /y %wtsif% usb_xpbt\$WIN_NT$.~BT\winnt.sif | makebt\tee.bat -a usb_log.txt

copy /y %wtsif% usb_xpbt\$WIN_NT$.~BT\winat.sif | makebt\tee.bat -a usb_log.txt

ECHO.>> usb_log.txt
ECHO.
IF EXIST %xpsource%\OEM\bin\DPsFnshr.7z (
  makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winnt.sif -rem -l:o command9  -s GuiRunOnce
  makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winnt.sif -add -create -l "     command9=%%SystemDrive%%\DPsFnshr.exe" -s GuiRunOnce
  makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -rem -l:o command9  -s GuiRunOnce
  makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -add -create -l "     command9=%%SystemDrive%%\DPsFnshr.exe" -s GuiRunOnce
)
xcopy makebt\ren_fold.cmd usb_xpbt\$WIN_NT$.~LS\I386 | makebt\tee.bat -a usb_log.txt
ECHO.>> usb_log.txt
ECHO.
xcopy makebt\undoren.cmd usb_xpbt\$WIN_NT$.~LS\I386 | makebt\tee.bat -a usb_log.txt
ECHO.>> usb_log.txt
ECHO.
copy /y %btini% usb_xpbt\boot.ini | makebt\tee.bat -a usb_log.txt
ECHO.>> usb_log.txt
ECHO.
IF %amd_64% EQU 1 (
  xcopy %xpsource%\AMD64\txtsetup.sif usb_xpbt\ /y /r /h | makebt\tee.bat -a usb_log.txt
  ECHO.>> usb_log.txt
) ELSE (
  xcopy %xpsource%\i386\txtsetup.sif usb_xpbt\ /y /r /h | makebt\tee.bat -a usb_log.txt
  ECHO.>> usb_log.txt
  ECHO.
  xcopy %xpsource%\i386\bootfont.bin usb_xpbt\ /y /r /h | makebt\tee.bat -a usb_log.txt
  ECHO.>> usb_log.txt
)
ECHO.
xcopy %xpsource%\i386\ntdetect.com usb_xpbt\ /y /r /h | makebt\tee.bat -a usb_log.txt
ECHO.>> usb_log.txt
ECHO.
xcopy %xpsource%\i386\ntldr usb_xpbt\ /y /r /h | makebt\tee.bat -a usb_log.txt
ECHO.>> usb_log.txt
ECHO.
:: xcopy %xpsource%\i386\setupldr.bin usb_xpbt\ /y /r /h | makebt\tee.bat -a usb_log.txt
:: ECHO.>> usb_log.txt
:: ECHO.
ECHO >> usb_log.txt Copy setupldr.bin Renamed as XPSTP because of 5 letter-limit in NTFS BootSector
copy /y %xpsource%\i386\setupldr.bin usb_xpbt\XPSTP | makebt\tee.bat -a usb_log.txt
::
:: Default is Unattended Setup using XPSTP as SetupLoader
:: And for Attended Setup we use XATSP as SetupLoader, where all winnt.sif are replaced by winat.sif
::
copy /y %xpsource%\i386\setupldr.bin usb_xpbt\XATSP | makebt\tee.bat -a usb_log.txt
makebt\gsar -b -o -swinnt.sif -rwinat.sif usb_xpbt\XATSP | makebt\tee.bat -a usb_log.txt

ECHO.>> usb_log.txt
ECHO.
ECHO >> usb_log.txt Custom files and XP Root files Copied to Temporary Folder usb_xpbt Ready
ECHO.>> usb_log.txt

ECHO  Adding lines to TXTSETUP.SIF ....

IF %amd_64% EQU 1 (
  makebt\fedit -f usb_xpbt\txtsetup.sif -add -once -l "ren_fold.cmd = 55,,,,,,_x,2,0,0" -s SourceDisksFiles
  makebt\fedit -f usb_xpbt\txtsetup.sif -add -once -l "undoren.cmd = 55,,,,,,_x,2,0,0" -s SourceDisksFiles
  makebt\fedit -f usb_xpbt\txtsetup.sif -add -once -l "binifix4.cmd = 55,,,,,,_x,2,0,0" -s SourceDisksFiles
) ELSE (
  makebt\fedit -f usb_xpbt\txtsetup.sif -add -once -l "ren_fold.cmd = 100,,,,,,_x,2,0,0" -s SourceDisksFiles
  makebt\fedit -f usb_xpbt\txtsetup.sif -add -once -l "undoren.cmd = 100,,,,,,_x,2,0,0" -s SourceDisksFiles
  makebt\fedit -f usb_xpbt\txtsetup.sif -add -once -l "binifix4.cmd = 100,,,,,,_x,2,0,0" -s SourceDisksFiles
)

:: Added for USB hard drives, loads rdummy.sys during Text Setup, which makes usbstor to see USB HD-drives as removable
IF "%usb_type%" == "USB-Harddisk" (
   makebt\fedit -f usb_xpbt\txtsetup.sif -add -once -l "rdummy.sys = 1,,,,,,4_,4,1,,,1,4" -s SourceDisksFiles
   makebt\fedit -f usb_xpbt\txtsetup.sif -add -once -l "rdummy = rdummy.sys,4" -s SCSI.Load
   makebt\fedit -f usb_xpbt\txtsetup.sif -add -once -l "rdummy = \"USB hard disk as removable\"" -s SCSI
   makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winnt.sif -add -create -l "\"sc config rdummy start= disabled"" -s GuiRunOnce
   makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -add -create -l "\"sc config rdummy start= disabled"" -s GuiRunOnce
   ECHO >> usb_log.txt Adding rdummy.sy_ to make Fixed USB-Harddisk seen in XP Setup as Removable Device
   copy makebt\rdummy.sy_ usb_xpbt\$WIN_NT$.~LS\I386 | makebt\tee.bat -a usb_log.txt
   copy makebt\rdummy.sy_ usb_xpbt\$WIN_NT$.~BT | makebt\tee.bat -a usb_log.txt
   ECHO.>> usb_log.txt
)

ECHO >> usb_log.txt Adding lines to TXTSETUP.SIF Ready

ECHO.
ECHO  Adding lines to WINNT.SIF ....
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winnt.sif -add -create -l ";  " -s GuiRunOnce
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winnt.sif -add -create -l ";  Changed by USB_MultiBoot for INSTALL XP from USB" -s GuiRunOnce
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winnt.sif -add -create -l ";  " -s GuiRunOnce
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winnt.sif -add -create -l "\"undoren.cmd"" -s GuiRunOnce
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winnt.sif -add -create -l "\"binifix4.cmd c:"" -s GuiRunOnce
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winnt.sif -add -create -l "UserExecute = \"ren_fold.cmd\"" -s SetupParams
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winnt.sif -rem -l:o = -s unattended
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winnt.sif -rem -l [unattended]
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winnt.sif -rem -l:o MsDosInitiated -s Data
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winnt.sif -rem -l:o floppyless -s Data
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winnt.sif -add -create -l "floppyless=1" -s Data
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winnt.sif -add -create -l "MsDosInitiated=1" -s Data

makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -add -create -l ";  " -s GuiRunOnce
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -add -create -l ";  Changed by USB_MultiBoot for INSTALL XP from USB" -s GuiRunOnce
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -add -create -l ";  " -s GuiRunOnce
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -add -create -l "\"undoren.cmd"" -s GuiRunOnce
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -add -create -l "\"binifix4.cmd c:"" -s GuiRunOnce
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -add -create -l "UserExecute = \"ren_fold.cmd\"" -s SetupParams
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -rem -l:o = -s unattended
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -rem -l [unattended]
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -rem -l:o MsDosInitiated -s Data
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -rem -l:o floppyless -s Data
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -add -create -l "floppyless=1" -s Data
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -add -create -l "MsDosInitiated=1" -s Data

makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -rem -l:o productkey -s UserData
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -rem -l:o FullName -s UserData
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -rem -l:o OrgName -s UserData
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -rem -l:o ComputerName -s UserData
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -rem -l:o TimeZone -s GuiUnattended
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -rem -l:o AdminPassword -s GuiUnattended
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -rem -l:o JoinWorkgroup -s Identification

makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -rem -l:o unattendswitch -s Data
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -add -create -l "unattendswitch=\"No\"" -s Data
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -rem -l:o UnattendedInstall -s Data
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -add -create -l "UnattendedInstall=\"No\"" -s Data
:: makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -rem -l:o EulaComplete -s Data
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -rem -l:o OEMSkipRegional -s GuiUnattended
makebt\fedit -f usb_xpbt\$WIN_NT$.~BT\winat.sif -add -create -l "OEMSkipRegional=\"0\"" -s GuiUnattended

ECHO.
ECHO.>> usb_log.txt
ECHO >> usb_log.txt Adding lines to WINNT.SIF Ready
ECHO.>> usb_log.txt

:: $OEM$\CMDLINES.TXT is used for making UserAccounts and install of Registry Tweaks at T-12
:: Info see: http://unattended.msfn.org/unattended.xp/   Reference

IF EXIST %oemd_dir%\nul (
  ECHO  Adding $OEM$ folder with UserAccounts and Registry Tweaks
  ECHO >> usb_log.txt Adding $OEM$ folder with UserAccounts and Registry Tweaks
  xcopy %oemd_dir%\*.* usb_xpbt\$WIN_NT$.~LS\$OEM$\ /i /k /e /r /y /h | makebt\tee.bat -a usb_log.txt

  IF "%xpsetup%"=="Undefined" (
    ECHO >> usb_log.txt  No Changes - XPSETUP = %xpsetup%   USER_NAME = %usernm% 
    ECHO >> usb_log.txt  Adding $OEM$ folder with Registry Tweaks Ready
    goto _no_userac
  )

  IF "%usernm%"=="Unknown" (
    ECHO >> usb_log.txt  No Changes - XPSETUP = %xpsetup%   USER_NAME = %usernm% 
    ECHO >> usb_log.txt  Adding $OEM$ folder with Registry Tweaks Ready
    goto _no_userac
  )

  IF EXIST usb_xpbt\$WIN_NT$.~LS\$OEM$\useraccounts.cmd (
    copy /y usb_xpbt\$WIN_NT$.~LS\$OEM$\useraccounts.cmd usb_xpbt\$WIN_NT$.~LS\$OEM$\useraccounts_cmd_bak.txt
    del usb_xpbt\$WIN_NT$.~LS\$OEM$\useraccounts.cmd
  )
  IF "%usernm%"=="None" (
    ECHO >> usb_log.txt  useraccounts.cmd Deleted - XPSETUP = %xpsetup%   USER_NAME = %usernm%
  ) ELSE (
    ECHO net user "%usernm%" /add>usb_xpbt\$WIN_NT$.~LS\$OEM$\useraccounts.cmd
    ECHO net localgroup Administrators "%usernm%" /add>>usb_xpbt\$WIN_NT$.~LS\$OEM$\useraccounts.cmd
    ECHO net accounts /maxpwage:unlimited>>usb_xpbt\$WIN_NT$.~LS\$OEM$\useraccounts.cmd
    ECHO EXIT>>usb_xpbt\$WIN_NT$.~LS\$OEM$\useraccounts.cmd
    ECHO >> usb_log.txt  New useraccounts.cmd was made - XPSETUP = %xpsetup%   USER_NAME = %usernm%
  )

  ECHO >> usb_log.txt Adding $OEM$ folder with UserAccounts and Registry Tweaks Ready
)
ECHO.

:_no_userac

IF EXIST %xpsource%\I386\presetup.cmd (
   ECHO  Adding Custom presetup.cmd for BTS DriverPacks ....
   echo.>> usb_log.txt
   xcopy makebt\presetup.cmd usb_xpbt\$WIN_NT$.~LS\I386\ /r /y /h | makebt\tee.bat -a usb_log.txt
   ECHO.>> usb_log.txt
   ECHO >> usb_log.txt presetup.cmd could give Windows ERROR Alert: No Disk due to Cardreader, Use Continue XP Setup
   ECHO >> usb_log.txt presetup.cmd was changed to limit the range for Finding Drives with OEM TAGFILE
   ECHO >> usb_log.txt presetup.cmd was changed to Delete setupold.exe , necessary for Repair Install Windows XP option
)

ECHO.
ECHO  *** Make Temporary Folder usb_xpbt with Custom XP Setup BootFiles Ready ***
ECHO.
ECHO.>> usb_log.txt
ECHO >> usb_log.txt *** Make Temporary Folder usb_xpbt with Custom XP Setup BootFiles Ready ***
ECHO.>> usb_log.txt

:: ==========================================================================================================================
:: ======== PART 2 - Backup Bootsector Files, Copy USB Content Source to USB-Drive, Make BootSector Files ===================
:: ==========================================================================================================================



ECHO  =============================================================================
ECHO  === PART 2 - Copy USB Content Source to USB-Drive, Make BootSector Files ====
ECHO  =============================================================================
ECHO >> usb_log.txt =============================================================================
ECHO >> usb_log.txt === PART 2 - Copy USB Content Source to USB-Drive, Make BootSector Files ====
ECHO >> usb_log.txt =============================================================================
ECHO.>> usb_log.txt

SET /A u_LS_folder=0

if EXIST %usbdrive%\$WIN_NT$.~LS\nul (
  IF EXIST u_script\FolderSize_U.vbs (
    FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSize_U.vbs %usbdrive%\$WIN_NT$.~LS') DO SET Conf=%%A
    IF !Conf! GTR 1000000 (
      SET /A u_LS_folder=!Conf:~0,-6!
    ) ELSE (
      SET u_LS_folder=1
    )
  )
) 

echo  drives   = %drlist%
echo  mkbtpath = %_mypath%
echo  usb_type = %usb_type%   usbdrive = %usbdrive%  has FileSystem = %FileSys%
echo  xpsource = %xpsource%
echo  ucontent = %usbconfg%
echo  bartpe   = %bartpe_dir%
echo  vista    = %vista_dir%
echo  oemd_dir = %oemd_dir%
echo  xpsetup  = %xpsetup%   UserName = %usernm%
echo.
ECHO  USB-Drive - 50 = %u_mb% MB   Existing Folder $WIN_NT$.~LS = !u_LS_folder! MB
ECHO  USB-Drive FREE = !u_free! MB + 50 MB Reserved 
ECHO  Content Source = !u_con! MB   Windows XP Source Folders    = !u_xpfolder! MB
ECHO  BartPE  Source = !u_bart! MB   Vista Source = !u_vista! MB
ECHO.
ECHO >> usb_log.txt USB-Drive - 50 = %u_mb% MB   Existing Folder $WIN_NT$.~LS = !u_LS_folder! MB
ECHO >> usb_log.txt USB-Drive FREE = !u_free! MB + 50 MB Reserved 
ECHO >> usb_log.txt Content Source = !u_con! MB   Windows XP Source + OEM Fold = !u_xpfolder! MB
ECHO >> usb_log.txt BartPE  Source = !u_bart! MB   Vista Source = !u_vista! MB
ECHO.>> usb_log.txt

SET /A UC_BP=!u_con! + !u_bart! + !u_vista!
IF !u_free! LSS !UC_BP! (
  ECHO  ***** USB-Drive Free Size TOO SMALL to Add Extra Sources - WARNING  *****
  ECHO.
  ECHO >> usb_log.txt ***** USB-Drive Free Size TOO SMALL to Add Extra Sources - WARNING  *****
  ECHO.>> usb_log.txt
)

SET /A UC_XP_LS=!u_con! + !u_xpfolder! - !u_LS_folder! + !u_bart! + !u_vista! 
IF !u_free! LSS !UC_XP_LS! (
  ECHO  ============================================================================= 
  ECHO  **** USB-Drive Free Size TOO SMALL to Add XP + Extra Sources - WARNING  ****
  ECHO  ============================================================================= 
  ECHO >> usb_log.txt **** USB-Drive Free Size TOO SMALL to Add XP + Extra Sources - WARNING  ****
  ECHO.>> usb_log.txt
)

ECHO  Copy XP Source To USB-Drive - about 15 minutes
ECHO.
ECHO  Yes = Copy XP + Extra Sources To USB-Drive
ECHO  No  = Only Copy Extra Sources To USB-Drive
ECHO  Cancel = STOP - End Program
ECHO.

set copyxp=y
IF EXIST u_script\Msg_CopyXPToUSB.vbs (
     FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_CopyXPToUSB.vbs') DO SET Conf=%%A
     IF "!Conf!"=="6" SET copyxp=y
     IF "!Conf!"=="7" SET copyxp=n
     IF "!Conf!"=="2" SET copyxp=c
) ELSE (
  SET /P Conf= Please enter y / n / c:
  SET copyxp=!Conf:~0,1!
)
IF /I !copyxp!.==c. GOTO _end_quit

IF /I !copyxp!.==y. (

  set Confirm=n

  if EXIST %usbdrive%\$WIN_NT$.~LS\nul (
        echo  *** Multiple XP next to Existing Folder $WIN_NT$.~LS on USB-Drive ? ***
        echo.
        echo  Yes = Create New XP Source next to Existing XP on USB-Drive - 15 minutes
        echo  No  = Update Existing Folders $WIN_NT$.~LS and $WIN_NT$.~BT on USB-Drive
        echo.
        echo >> usb_log.txt  *** Multiple XP next to Existing Folder $WIN_NT$.~LS on USB-Drive ? ***
        echo.>> usb_log.txt  
        echo >> usb_log.txt  Yes = Create New XP Source next to Existing XP on USB-Drive - 15 minutes
        echo >> usb_log.txt  No  = Update Existing Folders $WIN_NT$.~LS and $WIN_NT$.~BT on USB-Drive
        echo.>> usb_log.txt
    IF EXIST u_script\Msg_Multi_XP.vbs (
       FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_Multi_XP.vbs') DO SET Conf=%%A
       IF "!Conf!"=="6" SET Confirm=y
    ) ELSE (
      SET /P Confirm= Create next New XP Source on USB-Drive, Continue ?  Please enter y/n: 
      SET Confirm=!Confirm:~0,1! 
    )
    IF /I !Confirm!.==y. GOTO _multi_xp
  )

  set Confirm=n

  if EXIST %usbdrive%\$WIN_01$.~LS\nul (
        echo  *** Multiple XP next to Existing Folder $WIN_01$.~LS on USB-Drive ? ***
        echo.
        echo  Yes = Create New XP Source next to Existing XP on USB-Drive - 15 minutes
        echo  No  = STOP - End Program
        echo.
        echo >> usb_log.txt  *** Multiple XP next to Existing Folder $WIN_01$.~LS on USB-Drive ? ***
        echo.>> usb_log.txt  
        echo >> usb_log.txt  Yes = Create New XP Source next to Existing XP on USB-Drive - 15 minutes
        echo >> usb_log.txt  No  = STOP - End Program
        echo.>> usb_log.txt
    IF EXIST u_script\Msg_Multi_XP01.vbs (
       FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_Multi_XP01.vbs') DO SET Conf=%%A
       IF "!Conf!"=="6" SET Confirm=y
    ) ELSE (
      SET /P Confirm= Create next New XP Source on USB-Drive, Continue ?  Please enter y/n: 
      SET Confirm=!Confirm:~0,1! 
    )
    IF /I !Confirm!.==y. (
      GOTO _multi_xp
    ) ELSE (
      GOTO _end_quit
    )
  )
)


ECHO.
ECHO  Making Backups on USB-Drive and Preparing for FileCopy ....
ECHO.
ECHO >> usb_log.txt Making Backups on USB-Drive and Preparing for FileCopy ....
ECHO.>> usb_log.txt

:: Make btsec Folder on usbdrive for Bootsector Files
::
IF NOT EXIST %usbdrive%\btsec\nul MD %usbdrive%\btsec

IF EXIST %usbdrive%\boot.ini (
   ATTRIB -h -r -s %usbdrive%\boot.ini
   copy /y %usbdrive%\boot.ini %usbdrive%\boot_ini_bak.txt
   ECHO.
)
IF EXIST %usbdrive%\Bootfont.bin ATTRIB -h -r -s %usbdrive%\Bootfont.bin
IF EXIST %usbdrive%\NTDETECT.COM ATTRIB -h -r -s %usbdrive%\NTDETECT.COM
IF EXIST %usbdrive%\ntldr ATTRIB -h -r -s %usbdrive%\ntldr

IF EXIST %usbdrive%\btsec\BackupBS.ori (
   ATTRIB -h -r -s %usbdrive%\btsec\BackupBS.ori
   del %usbdrive%\btsec\BackupBS.ori
)

IF EXIST %usbdrive%\btsec\NTBOOT.bs copy /y %usbdrive%\btsec\NTBOOT.bs %usbdrive%\btsec\NTBOOT_bs.bak
IF EXIST %usbdrive%\btsec\XPSTP.bs copy /y %usbdrive%\btsec\XPSTP.bs %usbdrive%\btsec\XPSTP_bs.bak
IF EXIST %usbdrive%\btsec\PELDR.bs copy /y %usbdrive%\btsec\PELDR.bs %usbdrive%\btsec\PELDR_bs.bak
IF EXIST %usbdrive%\btsec\BOOTMGR.bs copy /y %usbdrive%\btsec\BOOTMGR.bs %usbdrive%\btsec\BOOTMGR_bs.bak
IF EXIST %usbdrive%\btsec\MSBOOT.bs copy /y %usbdrive%\btsec\MSBOOT.bs %usbdrive%\btsec\MSBOOT_bs.bak
IF EXIST %usbdrive%\btsec\FDBOOT.bs copy /y %usbdrive%\btsec\FDBOOT.bs %usbdrive%\btsec\FDBOOT_bs.bak
IF EXIST %usbdrive%\btsec\SLBOOT.bs copy /y %usbdrive%\btsec\SLBOOT.bs %usbdrive%\btsec\SLBOOT_bs.bak

ECHO.
ECHO  Copy Files to USB-Drive Start - Date = %DATE% %TIME:~0,8%
ECHO >> usb_log.txt Copy Files to USB-Drive Start - Date = %DATE% %TIME:~0,8%
echo.>> usb_log.txt
ECHO.

IF "%logtype%" == "Simple" (
  ECHO  Date = !DATE! !TIME:~0,8!
  ECHO  USB Content Source Folder           Copy to USB-Drive is Running ....
  echo >> usb_log.txt USB Content Source Folder   Copy to USB-Drive Begin   Date = !DATE! !TIME:~0,8!
  xcopy %usbconfg%\*.* %usbdrive%\  /i /k /e /r /y /h
  echo >> usb_log.txt USB Content Source Folder   Copy to USB-Drive Ready   Date = !DATE! !TIME:~0,8!
  ECHO.>> usb_log.txt
) ELSE (
  ECHO  Date = !DATE! !TIME:~0,8!
  ECHO  USB Content Source Folder           Copy to USB-Drive is Running ....
  ECHO  Please Wait about 15 minutes .....  STOP with [Ctrl][C] 
  echo >> usb_log.txt USB Content Source Folder   Copy to USB-Drive Begin   Date = !DATE! !TIME:~0,8!
  xcopy %usbconfg%\*.* %usbdrive%\  /i /k /e /r /y /h | makebt\tee.bat -a usb_log.txt
  echo >> usb_log.txt USB Content Source Folder   Copy to USB-Drive Ready   Date = !DATE! !TIME:~0,8!
  ECHO.>> usb_log.txt
)
echo.
echo  USB Content Source Folder   Copy to USB-Drive Ready
ECHO  Date = !DATE! !TIME:~0,8!
echo.



ECHO  >> usb_log.txt Copy XP BootFiles and boot.ini If not exist .....
echo.
ECHO Copy XP BootFiles and boot.ini If not exist .....

IF EXIST %usbdrive%\boot.ini (
   ATTRIB -h -r -s %usbdrive%\boot.ini
   ECHO.>> usb_log.txt
   ECHO.
)

IF NOT EXIST %usbdrive%\boot.ini (
  xcopy usb_xpbt\boot.ini %usbdrive%\ /y /r /h | makebt\tee.bat -a usb_log.txt
  ECHO.
  ECHO.>> usb_log.txt
)

IF EXIST usb_xpbt\bootfont.bin (
  xcopy usb_xpbt\bootfont.bin %usbdrive%\ /y /r /h | makebt\tee.bat -a usb_log.txt
  ECHO.
  ECHO.>> usb_log.txt
)

xcopy usb_xpbt\ntdetect.com %usbdrive%\ /y /r /h | makebt\tee.bat -a usb_log.txt
ECHO.
ECHO.>> usb_log.txt

xcopy usb_xpbt\ntldr %usbdrive%\ /y /r /h | makebt\tee.bat -a usb_log.txt
ECHO.
ECHO.>> usb_log.txt


IF "%rec_con%" == "YES" (
  ECHO.
  ECHO  Date = !DATE! !TIME:~0,8!
  ECHO  Recovery Console cmdcons Folder     Copy to USB-Drive is Running ....
  ECHO  Please Wait about 5 minutes .....   STOP with [Ctrl][C] 
  echo >> usb_log.txt cmdcons Folder   Copy to USB-Drive Begin   Date = !DATE! !TIME:~0,8!
  xcopy usb_xpbt\cmdcons\*.* %usbdrive%\cmdcons\ /i /k /e /r /y /h
  echo >> usb_log.txt cmdcons Folder   Copy to USB-Drive Ready   Date = !DATE! !TIME:~0,8!
  ECHO.>> usb_log.txt
  echo.
  echo  Recovery Console cmdcons Folder   Copy to USB-Drive Ready
  ECHO.
)

ECHO  Make Bootsector Files in btsec Folder ....
ECHO.
ECHO >> usb_log.txt Make Bootsector Files in btsec Folder ....
ECHO.>> usb_log.txt

IF NOT EXIST %usbdrive%\XPSTP (
  IF EXIST %usbdrive%\SETUPLDR.BIN (
    ECHO >> usb_log.txt Update - Rename SETUPLDR.BIN to XPSTP
    copy /Y %usbdrive%\SETUPLDR.BIN %usbdrive%\XPSTP | makebt\tee.bat -a usb_log.txt
  ) ELSE (
    xcopy usb_xpbt\XPSTP %usbdrive%\ /y /r /h | makebt\tee.bat -a usb_log.txt
  )
  ECHO.
  ECHO.>> usb_log.txt
)
xcopy usb_xpbt\XATSP %usbdrive%\ /y /r /h | makebt\tee.bat -a usb_log.txt

ECHO  Make BootSector File for TXT Mode Setup XP and make entry in boot.ini

FIND "C:\btsec\XPSTP.bs" %usbdrive%\boot.ini >NUL

IF %ERRORLEVEL%==0 (
  CALL makebt\MakeBS3.cmd %usbdrive%\XPSTP
) ELSE (
  CALL makebt\MakeBS3.cmd %usbdrive%\XPSTP /a "1. Begin TXT Mode Setup Windows XP, Never unplug USB-Drive Until Logon"
)

ECHO.
ECHO  Make BootSector File for Attended Setup XP and make entry in boot.ini

FIND "C:\btsec\XATSP.bs" %usbdrive%\boot.ini >NUL

IF %ERRORLEVEL%==0 (
  CALL makebt\MakeBS3.cmd %usbdrive%\XATSP
) ELSE (
  CALL makebt\MakeBS3.cmd %usbdrive%\XATSP /a "Attended Setup XP, Never unplug USB-Drive Until After Logon"
)

echo >> usb_log.txt BootSector Files for TXT Mode Setup XP were made

ECHO.
ECHO.>> usb_log.txt

makebt\mkbt.exe -x -c %usbdrive% makebt\bs_temp\NTBOOT.bs

FIND "FAT16" makebt\bs_temp\NTBOOT.bs >NUL

::  Direct Booting with FREEDOS from USB Removed since there were too few cases successful
:: 
::  copy /y makebt\BS_F16\f16frdos.bin makebt\bs_temp\f16frdos.bs
::  IF EXIST makebt\bs_temp\f16frdos.bs makebt\dsfi.exe makebt\bs_temp\f16frdos.bs 11 51 makebt\bs_temp\bpb_f16.bin
::  copy /y makebt\bs_temp\f16frdos.bs %usbdrive%\btsec\FDBOOT.bs
::
::    makebt\fedit -f %usbdrive%\boot.ini -rem -l:o FREEDOS


IF %ERRORLEVEL%==0 (
  ECHO FAT16 BootSector Detected - OK
  ECHO >> usb_log.txt FAT16 BootSector Detected - OK
  if exist %usbconfg%\usbmulti (
    ECHO TagFile usbmulti Detected - OK - Make Multi BootSector Files
    ECHO >> usb_log.txt TagFile usbmulti Detected - OK - Make Multi BootSector Files
    IF EXIST makebt\bs_temp\bpb_f16.bin ( 
      COPY /y makebt\bs_temp\bpb_f16.bin makebt\bs_temp\bpb_f16_bin.bak
      DEL makebt\bs_temp\bpb_f16.bin
    )
    makebt\dsfo.exe makebt\bs_temp\NTBOOT.bs 11 51 makebt\bs_temp\bpb_f16.bin

    copy /y makebt\BS_F16\f16btmgr.bin makebt\bs_temp\f16btmgr.bs
    IF EXIST makebt\bs_temp\f16btmgr.bs makebt\dsfi.exe makebt\bs_temp\f16btmgr.bs 11 51 makebt\bs_temp\bpb_f16.bin
    copy /y makebt\bs_temp\f16btmgr.bs %usbdrive%\btsec\BOOTMGR.bs

    copy /y makebt\BS_F16\f16msdos.bin makebt\bs_temp\f16msdos.bs
    IF EXIST makebt\bs_temp\f16msdos.bs makebt\dsfi.exe makebt\bs_temp\f16msdos.bs 11 51 makebt\bs_temp\bpb_f16.bin
    copy /y makebt\bs_temp\f16msdos.bs %usbdrive%\btsec\MSBOOT.bs

    IF "%syslin%"=="YES" (
      makebt\syslinux.exe -f %usbdrive%
      makebt\mkbt.exe -x -c %usbdrive% %usbdrive%\btsec\SLBOOT.bs
      makebt\mkbt.exe -x makebt\bs_temp\NTBOOT.bs %usbdrive%
    ) ELSE (
      makebt\fedit -f %usbdrive%\boot.ini -rem -l:o SYSLINUX
    )
    ECHO  Making of Multi BootSector Files - Ready
    ECHO >> usb_log.txt Making of Multi BootSector Files - Ready
  ) ELSE (
    makebt\fedit -f %usbdrive%\boot.ini -rem -l:o BOOTMGR
    makebt\fedit -f %usbdrive%\boot.ini -rem -l:o SYSLINUX
    makebt\fedit -f %usbdrive%\boot.ini -rem -l:o MS-DOS
    ECHO  No USB MultiBoot Content - Remove MS-DOS and WinPE 2.0 from boot.ini Menu
    ECHO >> usb_log.txt No USB MultiBoot Content - Remove MS-DOS and WinPE 2.0 from boot.ini Menu
  )
) ELSE (
  makebt\fedit -f %usbdrive%\boot.ini -rem -l:o BOOTMGR
  makebt\fedit -f %usbdrive%\boot.ini -rem -l:o SYSLINUX
  makebt\fedit -f %usbdrive%\boot.ini -rem -l:o MS-DOS
  ECHO  No FAT Format - Remove MS-DOS and WinPE 2.0 from boot.ini Menu
  ECHO >> usb_log.txt No FAT Format - Remove MS-DOS and WinPE 2.0 from boot.ini Menu
)

:: For FAT32 and NTFS Format  Windows PE 2.0  MS-DOS and FREEDOS will not boot from boot.ini Menu
:: Instead Use GRUB4DOS Menu for booting with DOS Floppy Images + Windows PE 2.0 and Install of Vista
:: 
:: makebt\BootSect.exe /nt60 %usbdrive% /force
:: makebt\mkbt.exe -x -c %usbdrive% %usbdrive%\btsec\BOOTMGR.bs
:: makebt\mkbt.exe -x makebt\bs_temp\NTBOOT.bs %usbdrive%

ECHO.
ECHO.>> usb_log.txt

:: ==========================================================================================================================
:: ================= PART 3 - Copy XP Source to USB-Drive ===================================================================
:: ==========================================================================================================================

IF /I !copyxp!.==n. GOTO _bartpe

ECHO  =============================================================================
ECHO  ================= PART 3 - Copy XP Source to USB-Drive ======================
ECHO  =============================================================================
ECHO >> usb_log.txt =============================================================================
ECHO >> usb_log.txt ================= PART 3 - Copy XP Source to USB-Drive ======================
ECHO >> usb_log.txt =============================================================================
ECHO.>> usb_log.txt

ECHO.
SET u_free=51
IF EXIST u_script\Msg_FreeSpace.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_FreeSpace.vbs %usbdrive%') DO SET Conf=%%A
  SET /A u_free=!Conf:~0,-3! - 50
)

ECHO  USB-Drive - 50 = %u_mb% MB   Existing Folder $WIN_NT$.~LS = !u_LS_folder! MB
ECHO  USB-Drive FREE = !u_free! MB + 50 MB Reserved 
ECHO  Win XP  Source = !u_xpfolder! MB
ECHO  BartPE  Source = !u_bart! MB   Vista Source = !u_vista! MB
ECHO.
ECHO >> usb_log.txt USB-Drive - 50 = %u_mb% MB   Existing Folder $WIN_NT$.~LS = !u_LS_folder! MB
ECHO >> usb_log.txt USB-Drive FREE = !u_free! MB + 50 MB Reserved 
ECHO >> usb_log.txt Win XP  Source = !u_xpfolder! MB
ECHO >> usb_log.txt BartPE  Source = !u_bart! MB   Vista Source = !u_vista! MB
ECHO.>> usb_log.txt

SET /A XP_LS=!u_xpfolder!-!u_LS_folder! + !u_bart! + !u_vista!

SET Confirm=y
SET cont_xp_flag=0
IF !u_free! LSS !XP_LS! (
  ECHO  *** USB-Drive Free Size TOO SMALL to Copy Source Folders - WARNING  ***
  ECHO.
  ECHO >> usb_log.txt *** USB-Drive Free Size TOO SMALL to Copy Source Folders - WARNING  ***
  ECHO.>> usb_log.txt
  IF EXIST u_script\Msg_Overflow_XP.vbs (
     FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_Overflow_XP.vbs') DO SET Conf=%%A
     IF "!Conf!"=="7" SET Confirm=n
  ) ELSE (
    SET /P Confirm= Overwrite USB-Drive with XP Source Files, Continue ?  Please enter y/n:
    SET Confirm=!Confirm:~0,1! 
  )
  IF /I !Confirm!.==n. GOTO _bartpe
  SET cont_xp_flag=1
)

IF !cont_xp_flag! EQU 1 GOTO :_cont_xp

set Confirm=y

if EXIST %usbdrive%\$WIN_NT$.~LS\nul (
	echo  ***** WARNING Existing Folder $WIN_NT$.~LS on USB-Drive Detected   *****
        echo.
        echo  Yes = Replace Files by Copy of XP Source to USB-Drive - 15 minutes
        echo  No  = Stop - Update USB-Drive with Total Commander Synchronize Dirs Asymmetric
        echo.
	echo >> usb_log.txt  ***** WARNING Existing Folder $WIN_NT$.~LS on USB-Drive Detected   *****
        echo.>> usb_log.txt  
        echo >> usb_log.txt  Yes = Replace Files by Copy of XP Source to USB-Drive - 15 minutes
        echo >> usb_log.txt  No  = STOP - Update USB-Drive with Total Commander Synchronize Dirs Asymmetric
        echo.>> usb_log.txt
  IF EXIST u_script\Msg_Exist_LS.vbs (
     FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_Exist_LS.vbs') DO SET Conf=%%A
     IF "!Conf!"=="7" SET Confirm=n
  ) ELSE (
    SET /P Confirm= Overwrite USB-Drive with XP Source Files, Continue ?  Please enter y/n: 
    SET Confirm=!Confirm:~0,1! 
  )
  IF /I !Confirm!.==n. GOTO _bartpe
)

:_cont_xp

ECHO.
ECHO  Date = !DATE! !TIME:~0,8!
ECHO  $WIN_NT$.~BT Folder                 Copy to USB-Drive is Running ....
ECHO  Please Wait about 5 minutes .....   STOP with [Ctrl][C] 
echo >> usb_log.txt $WIN_NT$.~BT Folder   Copy to USB-Drive Begin   Date = !DATE! !TIME:~0,8!
IF "%logtype%" == "Simple" (
  xcopy usb_xpbt\$WIN_NT$.~BT\*.* %usbdrive%\$WIN_NT$.~BT\ /i /k /e /r /y /h
) ELSE (
  xcopy usb_xpbt\$WIN_NT$.~BT\*.* %usbdrive%\$WIN_NT$.~BT\ /i /k /e /r /y /h | makebt\tee.bat -a usb_log.txt
)
echo >> usb_log.txt $WIN_NT$.~BT Folder   Copy to USB-Drive Ready   Date = !DATE! !TIME:~0,8!
ECHO.>> usb_log.txt
echo.
echo  $WIN_NT$.~BT Folder   Copy to USB-Drive Ready
ECHO.
xcopy usb_xpbt\txtsetup.sif %usbdrive%\ /y /r /h | makebt\tee.bat -a usb_log.txt
ECHO.>> usb_log.txt
ECHO.
:: xcopy usb_xpbt\setupldr.bin %usbdrive%\ /y /r /h | makebt\tee.bat -a usb_log.txt
:: ECHO.>> usb_log.txt
:: ECHO.
:: Instead Use setupldr.bin Renamed as XPSTP because of 5 letter-limit in NTFS BootSector
::
xcopy usb_xpbt\XPSTP %usbdrive%\ /y /r /h | makebt\tee.bat -a usb_log.txt
ECHO.>> usb_log.txt
ECHO.

ECHO.
ECHO  Copy XP folders cmpnents and i386 AMD64 to USB-Drive Folder $WIN_NT$.~LS
ECHO.
echo >> usb_log.txt Copy XPSOURCE Folders cmpnents and i386 - Begin   Date = !DATE! !TIME:~0,8!
IF "%lang_w98%" == "NO" (
  xcopy %xpsource%\i386\*.* %usbdrive%\$WIN_NT$.~LS\I386\ /i /k /e /r /y /h /EXCLUDE:makebt\NO_xcopy.txt
) ELSE (
  xcopy %xpsource%\i386\*.* %usbdrive%\$WIN_NT$.~LS\I386\ /i /k /e /r /y /h
)
IF EXIST %xpsource%\cmpnents\nul (
   xcopy %xpsource%\cmpnents\*.* %usbdrive%\$WIN_NT$.~LS\cmpnents\ /i /k /e /r /y /h
)
IF EXIST %xpsource%\AMD64\nul (
   xcopy %xpsource%\AMD64\*.* %usbdrive%\$WIN_NT$.~LS\AMD64\ /i /k /e /r /y /h
)
echo >> usb_log.txt Copy XP Folders cmpnents and i386 AMD64 - Ready   Date = !DATE! !TIME:~0,8!
echo.>> usb_log.txt

ECHO.
echo  Copy XP Folders cmpnents and i386 AMD64 to Folder $WIN_NT$.~LS - Ready
ECHO.

IF EXIST %xpsource%\I386\presetup.cmd (
   ECHO  Making Backup of presetup.cmd for BTS DriverPacks ....
   copy /y %xpsource%\I386\presetup.cmd %usbdrive%\$WIN_NT$.~LS\I386\presetup_cmd.bak
   ECHO.
)

ECHO  Copy Custom Files + $OEM$ Folder To USB-Drive
ECHO >> usb_log.txt Copy Custom Files + $OEM$ Folder To USB-Drive
xcopy usb_xpbt\$WIN_NT$.~LS\*.* %usbdrive%\$WIN_NT$.~LS\ /i /k /e /r /y /h | makebt\tee.bat -a usb_log.txt
echo.>> usb_log.txt
ECHO.

IF EXIST %xpsource%\OEM\bin\DPsFnshr.7z (
   ECHO  Adding OEM folder with BTS DriverPacks - Please Wait ....
   IF "%logtype%" == "Simple" (
     xcopy %xpsource%\OEM\*.* %usbdrive%\OEM\ /i /k /e /r /y /h
   ) ELSE (
     xcopy %xpsource%\OEM\*.* %usbdrive%\OEM\ /i /k /e /r /y /h | makebt\tee.bat -a usb_log.txt
   )
   echo >> usb_log.txt Adding OEM folder with BTS DriverPacks to USB-Drive Ready
   ECHO.>> usb_log.txt
   ECHO.
)

ECHO  FileCopy to USB-Drive is Ready - Date = %DATE% %TIME:~0,8%
ECHO.
ECHO >> usb_log.txt FileCopy to USB-Drive is Ready - Date = %DATE% %TIME:~0,8%
ECHO.>> usb_log.txt



:: ==========================================================================================================================
:: ================= PART 4 - Copy BartPE Source to USB-Drive ===============================================================
:: ==========================================================================================================================

:_bartpe


IF "%bartpe_dir%" == "" goto :_end_mig

ECHO  =============================================================================
ECHO  ================= PART 4 - Copy BartPE Source to USB-Drive ==================
ECHO  =============================================================================
ECHO.
ECHO >> usb_log.txt =============================================================================
ECHO >> usb_log.txt ================= PART 4 - Copy BartPE Source to USB-Drive ==================
ECHO >> usb_log.txt =============================================================================
ECHO.>> usb_log.txt

SET u_mini=1
SET u_prog=1
set Confirm=y

if EXIST %usbdrive%\minint\nul (
        echo.
	echo  ***** WARNING Existing BartPE Folder minint on USB-Drive Detected   *****
        echo.
        echo  Yes = Replace Files by Copy of BartPE Source to USB-Drive - 5 minutes
        echo  No  = Stop - End of Program
        echo.
        echo.>> usb_log.txt
	echo >> usb_log.txt  ***** WARNING Existing BartPE Folder minint on USB-Drive Detected   *****
        echo.>> usb_log.txt  
        echo >> usb_log.txt  Yes = Replace Files by Copy of BartPE Source to USB-Drive - 5 minutes
        echo >> usb_log.txt  No  = STOP - End of Program
        echo.>> usb_log.txt
  IF EXIST u_script\Msg_BartPE.vbs (
     FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_BartPE.vbs') DO SET Conf=%%A
     IF "!Conf!"=="7" SET Confirm=n
  ) ELSE (
    SET /P Confirm= Overwrite USB-Drive with BartPE Source Files, Continue ?  Please enter y/n: 
    SET Confirm=!Confirm:~0,1! 
  )
  IF /I !Confirm!.==n. GOTO _end_mig
  IF EXIST u_script\FolderSize_U.vbs (
    FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSize_U.vbs %usbdrive%\minint') DO SET Conf=%%A
    IF !Conf! GTR 1000000 (
      SET /A u_mini=!Conf:~0,-6!
    ) ELSE (
      SET u_mini=1
    )
  )
  IF EXIST u_script\FolderSize_U.vbs (
    FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSize_U.vbs %usbdrive%\Programs') DO SET Conf=%%A
    IF !Conf! GTR 1000000 (
      SET /A u_prog=!Conf:~0,-6!
    ) ELSE (
      SET u_prog=1
    )
  )
)

ECHO  Measuring FREESPACE - Please Wait .... 
ECHO.

ECHO.
SET u_free=51
IF EXIST u_script\Msg_FreeSpace.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_FreeSpace.vbs %usbdrive%') DO SET Conf=%%A
  SET /A u_free=!Conf:~0,-3! - 50
)

ECHO  USB-Drive - 50 = %u_mb% MB     Existing Folder minint   = !u_mini! MB
ECHO  USB-Drive FREE = !u_free! MB     Existing Folder Programs = !u_prog! MB
ECHO  BartPE  Source = !u_bart! MB
ECHO.
ECHO >> usb_log.txt USB-Drive - 50 = %u_mb% MB     Existing Folder minint   = !u_mini! MB
ECHO >> usb_log.txt USB-Drive FREE = !u_free! MB     Existing Folder Programs = !u_prog! MB 
ECHO >> usb_log.txt BartPE  Source = !u_bart! MB
ECHO.>> usb_log.txt

SET /A ex_bart=!u_bart! - !u_mini! - !u_prog!

IF !u_free! LSS !ex_bart! (
  ECHO.
  ECHO  ***** USB-Drive Free Size TOO SMALL for BartPE Source - End of Program *****
  ECHO.
  if NOT EXIST %usbdrive%\minint\nul (
    makebt\fedit -f %usbdrive%\boot.ini -rem -l:o BartPE
  )
  ECHO.>> usb_log.txt
  ECHO >> usb_log.txt ***** USB-Drive Free Size TOO SMALL for BartPE Source - End of Program *****
  ECHO.>> usb_log.txt
  IF EXIST u_script\Msg_Overflow_END.vbs CSCRIPT.EXE //NoLogo u_script\Msg_Overflow_END.vbs
  goto _end_mig
)

IF NOT EXIST %usbdrive%\minint\nul MD %usbdrive%\minint
IF NOT EXIST %usbdrive%\Programs\nul MD %usbdrive%\Programs

ECHO.
ECHO  Date = !DATE! !TIME:~0,8!
ECHO  BartPE Source Folder                Copy to USB-Drive is Running ....
ECHO  Please Wait about 5 minutes .....   STOP with [Ctrl][C] 
echo >> usb_log.txt BartPE Source Folder   Copy to USB-Drive Begin   Date = !DATE! !TIME:~0,8!
xcopy "%bartpe_dir%\i386\*.*" "%usbdrive%\minint\" /i /k /e /r /y /h
xcopy "%bartpe_dir%\Programs\*.*" "%usbdrive%\Programs\" /i /k /e /r /y /h

IF EXIST %bartpe_dir%\i386\winbom.ini (
  xcopy "%bartpe_dir%\i386\winbom.ini" "%usbdrive%\"  /r /y /h
)
echo >> usb_log.txt BartPE Source Folder   Copy to USB-Drive Ready   Date = !DATE! !TIME:~0,8!
ECHO.>> usb_log.txt
echo.
echo  BartPE Source Folder   Copy to USB-Drive Ready
ECHO.


:: ==========================================================================================================================
:: ================= PART 5 Finish - COPY VISTA TO USB - Change migrate.inf =================================================
:: ==========================================================================================================================

:_end_mig

ECHO  =============================================================================
ECHO  ============ PART 5 Finish - COPY VISTA TO USB - Change migrate.inf =========
ECHO  =============================================================================
ECHO.
ECHO >> usb_log.txt =============================================================================
ECHO >> usb_log.txt ============ PART 5 Finish - COPY VISTA TO USB - Change migrate.inf =========
ECHO >> usb_log.txt =============================================================================
ECHO.>> usb_log.txt


:: Create Patched PELDR and Make BartPE BootSector File Or Remove BartPE from boot.ini Menu

if exist %usbdrive%\minint\setupldr.bin (
  copy /y %usbdrive%\minint\setupldr.bin %usbdrive%\PELDR | makebt\tee.bat -a usb_log.txt
  makebt\gsar -b -o -sBT:x00:x00:x00\:x00:x00:x00txtsetup -rBT:x00:x00:x00\:x00:x00:x00notsetup %usbdrive%\PELDR | makebt\tee.bat -a usb_log.txt
  ECHO.>> usb_log.txt
  ECHO  Make BootSector File for BartPE
  ECHO >> usb_log.txt Make BootSector File for BartPE

  FIND "C:\btsec\PELDR.bs" %usbdrive%\boot.ini >NUL

  IF !ERRORLEVEL!==0 (
    CALL makebt\MakeBS3.cmd %usbdrive%\PELDR
  ) ELSE (
    CALL makebt\MakeBS3.cmd %usbdrive%\PELDR /a "5. BartPE - MINI XP"
  )

  ECHO >> usb_log.txt BootSector File for BartPE was made
) ELSE (
  makebt\fedit -f %usbdrive%\boot.ini -rem -l:o BartPE
  ECHO  No BartPE Folders - BartPE Removed from boot.ini Menu
  ECHO >> usb_log.txt No BartPE Folders - BartPE Removed from boot.ini Menu
)

ECHO.
ECHO.>> usb_log.txt

:: If No XP Setup Folders - Remove TXT Mode Setup from boot.ini Menu

if NOT EXIST %usbdrive%\$WIN_NT$.~BT\nul (
  makebt\fedit -f %usbdrive%\boot.ini -rem -l:o XPSTP
  makebt\fedit -f %usbdrive%\boot.ini -rem -l:o XATSP
  IF EXIST %usbdrive%\btsec\XPSTP.bs DEL %usbdrive%\btsec\XPSTP.bs
  IF EXIST %usbdrive%\btsec\XATSP.bs DEL %usbdrive%\btsec\XATSP.bs
  IF EXIST %usbdrive%\XPSTP DEL %usbdrive%\XPSTP
  IF EXIST %usbdrive%\XATSP DEL %usbdrive%\XATSP
  ECHO  No $WIN_NT$.~BT Folder - Remove XPSTP Setup from boot.ini
  ECHO >> usb_log.txt No $WIN_NT$.~BT Folder - Remove XPSTP Setup from boot.ini
  ECHO.
  ECHO.>> usb_log.txt
)

:: ================= COPY VISTA TO USB =================================================

IF "%vista_dir%" == "" (
  ECHO  No Vista Directory - Skip Vista Copy
  ECHO.
  ECHO >> usb_log.txt No Vista Directory - Skip Vista Copy
  ECHO.>> usb_log.txt
  goto :_ready
)

SET u_sources=1
set Confirm=y

if EXIST %usbdrive%\SOURCES\nul (
        echo.
	echo  ***** WARNING Existing Folder SOURCES on USB-Drive Detected   *****
        echo.
        echo  Yes = Replace Files by Copy of Vista Source to USB-Drive - 15 minutes
        echo  No  = Stop - End of Program
        echo.
        echo.>> usb_log.txt
	echo >> usb_log.txt  ***** WARNING Existing Folder SOURCES on USB-Drive Detected   *****
        echo.>> usb_log.txt  
        echo >> usb_log.txt  Yes = Replace Files by Copy of Vista Source to USB-Drive - 15 minutes
        echo >> usb_log.txt  No  = STOP - End of Program
        echo.>> usb_log.txt
  IF EXIST u_script\Msg_SOURCES.vbs (
     FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_SOURCES.vbs') DO SET Conf=%%A
     IF "!Conf!"=="7" SET Confirm=n
  ) ELSE (
    SET /P Confirm= Overwrite USB-Drive with Vista Source Files, Continue ?  Please enter y/n: 
    SET Confirm=!Confirm:~0,1! 
  )
  IF /I !Confirm!.==n. GOTO :_ready
  IF EXIST u_script\FolderSize_U.vbs (
    FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\FolderSize_U.vbs %usbdrive%\SOURCES') DO SET Conf=%%A
    IF !Conf! GTR 1000000 (
      SET /A u_sources=!Conf:~0,-6!
    ) ELSE (
      SET u_sources=1
    )
  )
)

ECHO  Measuring FREESPACE - Please Wait .... 
ECHO.

ECHO.
SET u_free=51
IF EXIST u_script\Msg_FreeSpace.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_FreeSpace.vbs %usbdrive%') DO SET Conf=%%A
  SET /A u_free=!Conf:~0,-3! - 50
)

ECHO  USB-Drive - 50 = %u_mb% MB     Existing Folder SOURCES   = !u_sources! MB
ECHO  USB-Drive FREE = !u_free! MB
ECHO  Vista   Source = !u_vista! MB
ECHO.
ECHO >> usb_log.txt USB-Drive - 50 = %u_mb% MB     Existing Folder SOURCES   = !u_sources! MB
ECHO >> usb_log.txt USB-Drive FREE = !u_free! MB
ECHO >> usb_log.txt Vista   Source = !u_vista! MB
ECHO.>> usb_log.txt

SET /A ex_vista=!u_vista! - !u_sources!

IF !u_free! LSS !ex_vista! (
  ECHO.
  ECHO  ***** USB-Drive Free Size TOO SMALL for Vista Source - End of Program *****
  ECHO.
  ECHO.>> usb_log.txt
  ECHO >> usb_log.txt ***** USB-Drive Free Size TOO SMALL for Vista Source - End of Program *****
  ECHO.>> usb_log.txt
  IF EXIST u_script\Msg_Overflow_END.vbs CSCRIPT.EXE //NoLogo u_script\Msg_Overflow_END.vbs
  goto :_ready
)


ECHO.
ECHO  Date = !DATE! !TIME:~0,8!
ECHO  Vista Source                        Copy to USB-Drive is Running ....
ECHO  Please Wait about 15 minutes .....  STOP with [Ctrl][C] 
echo >> usb_log.txt Vista Source - Copy to USB-Drive Begin   Date = !DATE! !TIME:~0,8!
xcopy "%vista_dir%\*.*" "%usbdrive%\" /i /k /e /r /y /h
echo >> usb_log.txt Vista Source - Copy to USB-Drive Ready   Date = !DATE! !TIME:~0,8!
ECHO.>> usb_log.txt
echo.
echo  Vista Source - Copy to USB-Drive Ready
ECHO.


:: ================= END COPY VISTA TO USB =============================================

:_ready

IF "%usb_type%" == "USB-Harddisk" (
  IF EXIST u_script\Msg_Ready.vbs CSCRIPT.EXE //NoLogo u_script\Msg_Ready.vbs
  GOTO :_end_quit
) 

SET Confirm=y
if EXIST %usbdrive%\$WIN_NT$.~BT\nul (
  ECHO  Make USB-stick in XP Setup to be Preferred Boot Drive U:  Enter: y
  ECHO.
  ECHO  For Mixed SATA / PATA Config: Don't change migrate.inf    Enter: n
  ECHO.
  IF EXIST u_script\Msg_Migrate.vbs (
     FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_Migrate.vbs') DO SET Conf=%%A
     IF "!Conf!"=="6" SET Confirm=y
     IF "!Conf!"=="7" SET Confirm=n
  ) ELSE (
    SET /P Conf= Please enter y/n: 
    SET Confirm=!Conf:~0,1!
  )

  IF /I !Confirm!.==y. (
     copy /y %usbdrive%\$WIN_NT$.~BT\migrate.inf %usbdrive%\$WIN_NT$.~BT\migrate_inf_bak.txt
     CALL makebt\MkMigrateInf2.cmd %usbdrive% %usbdrive%\$WIN_NT$.~BT\migrate.inf
     echo >> usb_log.txt USB-Drive becomes Boot Drive U: - MkMigrateInf2 Ready
     echo.>> usb_log.txt
  ) 
) ELSE (
  IF EXIST u_script\Msg_Ready.vbs CSCRIPT.EXE //NoLogo u_script\Msg_Ready.vbs
)
ECHO.
GOTO :_end_quit

:: ==========================================================================================================================
:: ================= PART 6 - Copy Multiple XP Source for Install from USB-Drive ============================================
:: ==========================================================================================================================

:_multi_xp

SET xp_nr=2

FOR /L %%G IN (2,1,9) DO (
  IF NOT EXIST %usbdrive%\$WIN_0%%G$.~LS\nul (
    SET xp_nr=%%G
    GOTO _valid_nr
  )
  SET test_nr=%%G
  IF "!test_nr!"=="9" (
     ECHO  Too many XP Install Sources on USB-Drive, Max = 9
     GOTO :_end_quit
     pause
  )
)

:_valid_nr

ECHO  =============================================================================
ECHO  ================= PART 6 - Copy Multiple XP Source to USB-Drive =============
ECHO  =============================================================================
ECHO >> usb_log.txt =============================================================================
ECHO >> usb_log.txt ================= PART 6 - Copy Multiple XP Source to USB-Drive =============
ECHO >> usb_log.txt =============================================================================
ECHO.>> usb_log.txt

:: Measure FreeSpace and Compare to XP Source

ECHO.
SET u_free=51
IF EXIST u_script\Msg_FreeSpace.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_FreeSpace.vbs %usbdrive%') DO SET Conf=%%A
  SET /A u_free=!Conf:~0,-3! - 50
)

ECHO  USB-Drive - 50 = %u_mb% MB
ECHO  USB-Drive FREE = !u_free! MB + 50 MB Reserved 
ECHO  Win XP  Source = !u_xpfolder! MB
ECHO.
ECHO >> usb_log.txt USB-Drive - 50 = %u_mb% MB
ECHO >> usb_log.txt USB-Drive FREE = !u_free! MB + 50 MB Reserved 
ECHO >> usb_log.txt Win XP  Source = !u_xpfolder! MB
ECHO.>> usb_log.txt

IF !u_free! LSS !u_xpfolder! (
  ECHO.
  ECHO  ***** USB-Drive Free Size TOO SMALL for XP Source - End of Program *****
  ECHO.
  ECHO.>> usb_log.txt
  ECHO >> usb_log.txt ***** USB-Drive Free Size TOO SMALL for XP Source - End of Program *****
  ECHO.>> usb_log.txt
  IF EXIST u_script\Msg_Overflow_END.vbs CSCRIPT.EXE //NoLogo u_script\Msg_Overflow_END.vbs
  goto :_end_quit
)


ECHO  >> usb_log.txt Copy XP BootFiles If not exist .....
echo.
ECHO Copy XP BootFiles If not exist .....

IF EXIST %usbdrive%\boot.ini (
   ATTRIB -h -r -s %usbdrive%\boot.ini
   ECHO.>> usb_log.txt
   ECHO.
)

IF NOT EXIST %usbdrive%\boot.ini (
  xcopy usb_xpbt\boot.ini %usbdrive%\ /y /r /h | makebt\tee.bat -a usb_log.txt
  ECHO.
  ECHO.>> usb_log.txt
)

IF NOT EXIST %usbdrive%\bootfont.bin (
  IF EXIST usb_xpbt\bootfont.bin (
    xcopy usb_xpbt\bootfont.bin %usbdrive%\ /y /r /h | makebt\tee.bat -a usb_log.txt
    ECHO.
    ECHO.>> usb_log.txt
  )
)

IF NOT EXIST %usbdrive%\ntdetect.com (
  xcopy usb_xpbt\ntdetect.com %usbdrive%\ /y /r /h | makebt\tee.bat -a usb_log.txt
  ECHO.
  ECHO.>> usb_log.txt
)

IF NOT EXIST %usbdrive%\ntldr (
  xcopy usb_xpbt\ntldr %usbdrive%\ /y /r /h | makebt\tee.bat -a usb_log.txt
  ECHO.
  ECHO.>> usb_log.txt
)

:: Rename $WIN_NT$.~BT and $WIN_NT$.~LS Folders and Do Patching
:: Make New BootSector Files for Original XP Source

if EXIST %usbdrive%\$WIN_NT$.~BT\nul (

  ECHO  Renaming $WIN_NT$.~BT and $WIN_NT$.~LS Folders - Please Wait ....

  ren %usbdrive%\$WIN_NT$.~BT $WIN_01$.~BT
  ren %usbdrive%\$WIN_NT$.~LS $WIN_01$.~LS
  ren %usbdrive%\txtsetup.sif txtset01.sif
  ren %usbdrive%\XPSTP XPS01

  makebt\gsar -b -o -s$WIN_NT$ -r$WIN_01$ %usbdrive%\XPS01 | makebt\tee.bat -a usb_log.txt
  makebt\gsar -b -o -stxtsetup.sif -rtxtset01.sif %usbdrive%\XPS01 | makebt\tee.bat -a usb_log.txt

  makebt\gsar -b -o -sWIN_NT -rWIN_01 %usbdrive%\$WIN_01$.~LS\I386\ren_fold.cmd | makebt\tee.bat -a usb_log.txt
  makebt\gsar -b -o -stxtsetup -rtxtset01 %usbdrive%\$WIN_01$.~LS\I386\ren_fold.cmd | makebt\tee.bat -a usb_log.txt

  makebt\gsar -b -o -sWIN_NT -rWIN_01 %usbdrive%\$WIN_01$.~LS\I386\undoren.cmd | makebt\tee.bat -a usb_log.txt
  makebt\gsar -b -o -stxtsetup -rtxtset01 %usbdrive%\$WIN_01$.~LS\I386\undoren.cmd | makebt\tee.bat -a usb_log.txt

  ECHO.>> usb_log.txt
  expand %usbdrive%\$WIN_01$.~BT\setupdd.sy_ %usbdrive%\$WIN_01$.~BT\setupdd.sys
  makebt\gsar -i -b -o -s$:x00W:x00I:x00N:x00_:x00N:x00T:x00$:x00.:x00~:x00L:x00S:x00 -r$:x00W:x00I:x00N:x00_:x000:x001:x00$:x00.:x00~:x00L:x00S:x00 %usbdrive%\$WIN_01$.~BT\setupdd.sys | makebt\tee.bat -a usb_log.txt
  copy /y %usbdrive%\$WIN_01$.~BT\setupdd.sys makebt\bs_temp\setupdd.sys
  makecab makebt\bs_temp\setupdd.sys makebt\bs_temp\setupdd.sy_
  ECHO.
  ECHO.>> usb_log.txt
  xcopy makebt\bs_temp\setupdd.sy_ %usbdrive%\$WIN_01$.~BT\ /y /r /h | makebt\tee.bat -a usb_log.txt

  makebt\fedit -f %usbdrive%\boot.ini -rem -l:o XPSTP
  makebt\fedit -f %usbdrive%\boot.ini -rem -l:o XATSP
  IF EXIST %usbdrive%\btsec\XPSTP.bs DEL %usbdrive%\btsec\XPSTP.bs
  IF EXIST %usbdrive%\btsec\XATSP.bs DEL %usbdrive%\btsec\XATSP.bs

  ECHO.  
  ECHO  Give NEW Name for Original XP in boot.ini Menu
  ECHO.
  ECHO.>> usb_log.txt  
  ECHO >> usb_log.txt Give NEW Name for Original XP in boot.ini Menu
  ECHO.>> usb_log.txt

  SET xp_name="Original XP"
  IF EXIST u_script\Input_XP_Orig.vbs (
    FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Input_XP_Orig.vbs') DO SET xp_name=%%A
  )

  ECHO  Make New BootSector File for TXT Mode Setup Original XP
  CALL makebt\MakeBS3.cmd %usbdrive%\XPS01 /a "01 TXT Mode Setup !xp_name!, Never unplug USB-Drive"
  echo >> usb_log.txt New BootSector File for TXT Mode Setup Original XP was made
  ECHO.
  ECHO.>> usb_log.txt

  IF EXIST %usbdrive%\XATSP (
    ren %usbdrive%\XATSP XAT01
    makebt\gsar -b -o -s$WIN_NT$ -r$WIN_01$ %usbdrive%\XAT01 | makebt\tee.bat -a usb_log.txt
    makebt\gsar -b -o -stxtsetup.sif -rtxtset01.sif %usbdrive%\XAT01 | makebt\tee.bat -a usb_log.txt
  )
  ECHO  Make New BootSector File for Attended Setup Original XP
  CALL makebt\MakeBS3.cmd %usbdrive%\XAT01 /a "01 Attended Setup !xp_name!, Never unplug USB-Drive"
  echo >> usb_log.txt New BootSector File for Attended Setup Original XP was made
  ECHO.
  ECHO.>> usb_log.txt

)


ECHO.  
ECHO  Give Name of EXTRA XP Source for boot.ini Menu
ECHO.
ECHO.>> usb_log.txt 
ECHO >> usb_log.txt Give Name of EXTRA XP Source for boot.ini Menu
ECHO.>> usb_log.txt

SET xp_name="Windows XP"
IF EXIST u_script\Input_XP_Name.vbs (
  FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Input_XP_Name.vbs') DO SET xp_name=%%A
)

:: Use XPS0%xp_nr% Instead of SETUPLDR.BIN , because of 5 letter-limit in NTFS BootSector
:: Make BootSector Files

copy /y usb_xpbt\XPSTP %usbdrive%\XPS0%xp_nr% | makebt\tee.bat -a usb_log.txt
copy /y usb_xpbt\XATSP %usbdrive%\XAT0%xp_nr% | makebt\tee.bat -a usb_log.txt
ECHO.
ECHO.>> usb_log.txt
ECHO  Make BootSector Files for TXT Mode Setup XP
CALL makebt\MakeBS3.cmd %usbdrive%\XPS0%xp_nr% /a "0%xp_nr% TXT Mode Setup %xp_name%, Never unplug USB-Drive"
ECHO.
CALL makebt\MakeBS3.cmd %usbdrive%\XAT0%xp_nr% /a "0%xp_nr% Attended Setup %xp_name%, Never unplug USB-Drive"
echo >> usb_log.txt BootSector Files for TXT Mode Setup XP were made

ECHO.
ECHO.>> usb_log.txt

:: Do FileCopy New XP Source

ECHO.
ECHO  Date = !DATE! !TIME:~0,8!
ECHO  $WIN_0%xp_nr%$.~BT Folder                 Copy to USB-Drive is Running ....
ECHO  Please Wait about 5 minutes .....   STOP with [Ctrl][C] 
echo >> usb_log.txt $WIN_0%xp_nr%$.~BT Folder   Copy to USB-Drive Begin   Date = !DATE! !TIME:~0,8!
IF "%logtype%" == "Simple" (
  xcopy usb_xpbt\$WIN_NT$.~BT\*.* %usbdrive%\$WIN_0%xp_nr%$.~BT\ /i /k /e /r /y /h
) ELSE (
  xcopy usb_xpbt\$WIN_NT$.~BT\*.* %usbdrive%\$WIN_0%xp_nr%$.~BT\ /i /k /e /r /y /h | makebt\tee.bat -a usb_log.txt
)
echo >> usb_log.txt $WIN_0%xp_nr%$.~BT Folder   Copy to USB-Drive Ready   Date = !DATE! !TIME:~0,8!
ECHO.>> usb_log.txt
echo.
echo  $WIN_0%xp_nr%$.~BT Folder   Copy to USB-Drive Ready
ECHO.
copy /y usb_xpbt\txtsetup.sif %usbdrive%\txtset0%xp_nr%.sif | makebt\tee.bat -a usb_log.txt
ECHO.>> usb_log.txt
ECHO.
ECHO.
ECHO  Copy XP folders cmpnents and i386 AMD64 to USB-Drive Folder $WIN_0%xp_nr%$.~LS
ECHO.
echo >> usb_log.txt Copy XPSOURCE Folders cmpnents and i386 - Begin   Date = !DATE! !TIME:~0,8!
IF "%lang_w98%" == "NO" (
  xcopy %xpsource%\i386\*.* %usbdrive%\$WIN_0%xp_nr%$.~LS\I386\ /i /k /e /r /y /h /EXCLUDE:makebt\NO_xcopy.txt
) ELSE (
  xcopy %xpsource%\i386\*.* %usbdrive%\$WIN_0%xp_nr%$.~LS\I386\ /i /k /e /r /y /h
)
IF EXIST %xpsource%\cmpnents\nul (
   xcopy %xpsource%\cmpnents\*.* %usbdrive%\$WIN_0%xp_nr%$.~LS\cmpnents\ /i /k /e /r /y /h
)
IF EXIST %xpsource%\AMD64\nul (
   xcopy %xpsource%\AMD64\*.* %usbdrive%\$WIN_0%xp_nr%$.~LS\AMD64\ /i /k /e /r /y /h
)
echo >> usb_log.txt Copy XP Folders cmpnents and i386 AMD64 - Ready   Date = !DATE! !TIME:~0,8!
echo.>> usb_log.txt

ECHO.
echo  Copy XP Folders cmpnents and i386 AMD64 to Folder $WIN_0%xp_nr%$.~LS - Ready
ECHO.

IF EXIST %xpsource%\I386\presetup.cmd (
   ECHO  Making Backup of presetup.cmd for BTS DriverPacks ....
   copy /y %xpsource%\I386\presetup.cmd %usbdrive%\$WIN_0%xp_nr%$.~LS\I386\presetup_cmd.bak
   ECHO.
)

ECHO  Copy Custom Files + $OEM$ Folder To USB-Drive
ECHO >> usb_log.txt Copy Custom Files + $OEM$ Folder To USB-Drive
xcopy usb_xpbt\$WIN_NT$.~LS\*.* %usbdrive%\$WIN_0%xp_nr%$.~LS\ /i /k /e /r /y /h | makebt\tee.bat -a usb_log.txt
echo.>> usb_log.txt
ECHO.

IF EXIST %xpsource%\OEM\bin\DPsFnshr.7z (
   ECHO  Adding OEM folder with BTS DriverPacks - Please Wait ....
   IF "%logtype%" == "Simple" (
     xcopy %xpsource%\OEM\*.* %usbdrive%\OEM\ /i /k /e /r /y /h
   ) ELSE (
     xcopy %xpsource%\OEM\*.* %usbdrive%\OEM\ /i /k /e /r /y /h | makebt\tee.bat -a usb_log.txt
   )
   echo >> usb_log.txt Adding OEM folder with BTS DriverPacks to USB-Drive Ready
   ECHO.>> usb_log.txt
   ECHO.
)

ECHO  FileCopy to USB-Drive is Ready - Date = %DATE% %TIME:~0,8%
ECHO.
ECHO >> usb_log.txt FileCopy to USB-Drive is Ready - Date = %DATE% %TIME:~0,8%
ECHO.>> usb_log.txt
ECHO >> usb_log.txt Customize for $WIN_0%xp_nr%$
ECHO.>> usb_log.txt

IF EXIST makebt\bs_temp\setupdd.sy_ (
  DEL makebt\bs_temp\setupdd.sys
  DEL makebt\bs_temp\setupdd.sy_
)

makebt\gsar -b -o -s$WIN_NT$ -r$WIN_0%xp_nr%$ %usbdrive%\XPS0%xp_nr% | makebt\tee.bat -a usb_log.txt
makebt\gsar -b -o -stxtsetup.sif -rtxtset0%xp_nr%.sif %usbdrive%\XPS0%xp_nr% | makebt\tee.bat -a usb_log.txt

makebt\gsar -b -o -s$WIN_NT$ -r$WIN_0%xp_nr%$ %usbdrive%\XAT0%xp_nr% | makebt\tee.bat -a usb_log.txt
makebt\gsar -b -o -stxtsetup.sif -rtxtset0%xp_nr%.sif %usbdrive%\XAT0%xp_nr% | makebt\tee.bat -a usb_log.txt

makebt\gsar -b -o -sWIN_NT -rWIN_0%xp_nr% %usbdrive%\$WIN_0%xp_nr%$.~LS\I386\ren_fold.cmd | makebt\tee.bat -a usb_log.txt
makebt\gsar -b -o -stxtsetup -rtxtset0%xp_nr% %usbdrive%\$WIN_0%xp_nr%$.~LS\I386\ren_fold.cmd | makebt\tee.bat -a usb_log.txt

makebt\gsar -b -o -sWIN_NT -rWIN_0%xp_nr% %usbdrive%\$WIN_0%xp_nr%$.~LS\I386\undoren.cmd | makebt\tee.bat -a usb_log.txt
makebt\gsar -b -o -stxtsetup -rtxtset0%xp_nr% %usbdrive%\$WIN_0%xp_nr%$.~LS\I386\undoren.cmd | makebt\tee.bat -a usb_log.txt

ECHO.>> usb_log.txt
expand %usbdrive%\$WIN_0%xp_nr%$.~BT\setupdd.sy_ %usbdrive%\$WIN_0%xp_nr%$.~BT\setupdd.sys
makebt\gsar -i -b -o -s$:x00W:x00I:x00N:x00_:x00N:x00T:x00$:x00.:x00~:x00L:x00S:x00 -r$:x00W:x00I:x00N:x00_:x000:x00%xp_nr%:x00$:x00.:x00~:x00L:x00S:x00 %usbdrive%\$WIN_0%xp_nr%$.~BT\setupdd.sys | makebt\tee.bat -a usb_log.txt
copy /y %usbdrive%\$WIN_0%xp_nr%$.~BT\setupdd.sys makebt\bs_temp\setupdd.sys
makecab makebt\bs_temp\setupdd.sys makebt\bs_temp\setupdd.sy_
ECHO.
ECHO.>> usb_log.txt
xcopy makebt\bs_temp\setupdd.sy_ %usbdrive%\$WIN_0%xp_nr%$.~BT\ /y /r /h | makebt\tee.bat -a usb_log.txt
ECHO.>> usb_log.txt

IF "%usb_type%" == "USB-Harddisk" (
  IF EXIST u_script\Msg_Ready.vbs CSCRIPT.EXE //NoLogo u_script\Msg_Ready.vbs
  GOTO :_end_quit
) 

:: Set USB-stick BootDrive Letter

SET Confirm=y
if EXIST %usbdrive%\$WIN_0%xp_nr%$.~BT\nul (
  ECHO  Make USB-stick in XP Setup to be Preferred Boot Drive U:  Enter: y
  ECHO.
  ECHO  For Mixed SATA / PATA Config: Don't change migrate.inf    Enter: n
  ECHO.
  IF EXIST u_script\Msg_Migrate.vbs (
     FOR /F "tokens=*" %%A IN ('CSCRIPT.EXE //NoLogo u_script\Msg_Migrate.vbs') DO SET Conf=%%A
     IF "!Conf!"=="6" SET Confirm=y
     IF "!Conf!"=="7" SET Confirm=n
  ) ELSE (
    SET /P Conf= Please enter y/n: 
    SET Confirm=!Conf:~0,1!
  )

  IF /I !Confirm!.==y. (
     copy /y %usbdrive%\$WIN_0%xp_nr%$.~BT\migrate.inf %usbdrive%\$WIN_0%xp_nr%$.~BT\migrate_inf_bak.txt
     CALL makebt\MkMigrateInf2.cmd %usbdrive% %usbdrive%\$WIN_0%xp_nr%$.~BT\migrate.inf
     echo >> usb_log.txt USB-Drive becomes Boot Drive U: - MkMigrateInf2 Ready
     echo.>> usb_log.txt
  ) 
) ELSE (
  IF EXIST u_script\Msg_Ready.vbs CSCRIPT.EXE //NoLogo u_script\Msg_Ready.vbs
)
ECHO.
GOTO :_end_quit


:: ==========================================================================================================================

:_end_quit
(
  ECHO  ============================================================================= 
  ECHO  *** HELP for Using MultiBoot USB-Drive *** Read Help_USB_MultiBoot.txt File
  ECHO  Boot with USB-Drive plugged and Press [Delete] or F2 to Enter BIOS Setup
  ECHO  Change BIOS Boot Settings: 
  ECHO  Harddisk is First Boot Device Type and USB-Drive is seen as First Harddisk
  ECHO  Reboot from USB-Drive and Make Selection from Boot Menu
  ECHO  ============================================================================= 
  ECHO  ***** HELP for Using USB-Drive for Install of Windows XP: *****
  ECHO.
  ECHO  First Remove ALL Other USB-Drives ** So Harddisk in Setup gets DriveLetter C 
  ECHO  Reboot from USB-Drive and Select  1. Begin TXT Mode Setup Windows XP
  ECHO  Use Only C: Drive of Computer Harddisk as Partition for Install of Windows XP
  ECHO  and then Select Quick Format with NTFS FileSystem, XP Install is Automatic
  ECHO. 
  ECHO  ***** NEVER UNPLUG USB-Drive ***** Until After First Logon of Windows XP
  ECHO.
  ECHO  New Harddisk and Creating Partitions after Booting from USB-Drive:
  ECHO  Direct after Deleting and Creating New partitions, Quit XP Setup with F3 
  ECHO  OR Switch OFF your Computer and Boot in any case from USB-Drive again and 
  ECHO  Run 1. TXT Mode Setup again so that DriveLetters get their Correct Value
  ECHO  So in this case one Boots ** TWICE ** in the TXT-mode Setup
  ECHO. 
  ECHO  End Program - USB_MultiBoot.CMD will be Closed - Date = %DATE% %TIME:~0,8%
  ECHO.
) | makebt\tee.bat -a usb_log.txt

IF "%OS%"=="Windows_NT" ENDLOCAL

:_end_tee
pause
EXIT

:_ERROR1
ECHO  ============================================================================= 
Echo  ***** ERROR - File %1 is Missing ***** 
ECHO  ============================================================================= 
pause
GOTO :_end_quit


:: ==========================================================================================================================
:: ====================================== END USB_MultiBoot.cmd =============================================================
:: ==========================================================================================================================
