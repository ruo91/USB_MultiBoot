@echo off
REM MkMigrateInf2.cmd v0.01
REM created by cdob, edit 20-08-2007

setlocal EnableExtensions

set Drive=%~d1
if %Drive%.==. set Drive=%~d0

set FileName=%~2
if %FileName%.==. set FileName=migrate_inf.txt

set MigrateDrive=U:
if not %~d3.==. set MigrateDrive=%~d3

set Value=
FOR /F "skip=2 tokens=1-2*" %%a IN ('reg query HKLM\System\MountedDevices /v \DosDevices\%Drive%') DO set Value=%%c

if %Value%.==. (echo drive settings %Drive% not found & goto :EOF)

set MigrateStr=%Value:~0,2%
set count=2
:begin_parse
  call :exec set MidStr=%%Value:~%count%,2%%
  if %MidStr%.==. goto :exit_parse
  set MigrateStr=%MigrateStr%,%MidStr%
  set /a count+=2
  goto begin_parse
:exit_parse

(echo [Version]
echo Signature = "$Windows NT$"
echo.
echo [Addreg]
echo HKLM,"SYSTEM\MountedDevices",,0x00000010
echo HKLM,"SYSTEM\ControlSet001\Control\StorageDevicePolicies","WriteProtect",%%REG_DWORD%%,1
echo HKLM,"SYSTEM\MountedDevices","\DosDevices\%MigrateDrive%",0x00030001,\
echo %MigrateStr%
echo.
echo [Strings]
echo ;Handy macro substitutions non-localizable
echo REG_SZ = 0x00000000
echo REG_BINARY = 0x00000001
echo REG_DWORD = 0x00010001
echo REG_MULTI_SZ = 0x00010000
echo REG_SZ_APPEND = 0x00010008
echo REG_EXPAND_SZ = 0x00020000
echo.)>%FileName%
rem pause
goto :EOF

:exec
  %*
goto :EOF