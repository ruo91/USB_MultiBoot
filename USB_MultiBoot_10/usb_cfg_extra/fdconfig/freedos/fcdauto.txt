@echo off
SET DEBUG=N
SET NLSPATH=A:\FREEDOS
set dircmd=/P /OGN /4 
set lang=EN
for %%X in ( 3 4 5 ) do if "%config%"=="%%X" goto livecd
SET PATH=A:\FREEDOS;A:\DRIVER

if !%config%==!2 goto safemode

set cputype=80386
getargs >NUL
if "%errorlevel%"=="255" set cputype=80286
if not "%errorlevel%"=="0" if not errorlevel 4 getargs > temp.bat
call temp.bat
del temp.bat

echo Checking for CDROM driver or c:\fdbootcd.iso...
devload /h /qq eltorito.sys /D:FDCD0001>NUL
if not exist FDCD0001 devload /h /qq xcdrom.sys /D:FDCD0001>NUL
if exist FDCD0001 devload /h /qq cdrcache.sys FDCD0001 CDRCACH1 1024 >NUL
if exist c:\fdbootcd.iso a:\driver\shsucdhd /f:c:\fdbootcd.iso >NUL
if exist FDCD0001 set loadcd=FDCD0001
if exist CDRCACH1 set loadcd=CDRCACH1
if exist SHSU-CDH set loadcd=SHSU-CDH
if !%loadcd%==! goto nocd
a:\driver\shsucdx /Q /D2 /D:?%loadcd%,X >NUL
if not exist X:\*.* goto nocd
echo CDROM found, checking for \freedos\setup\odin directory...
if not exist X:\FreeDOS\Setup\ODIN\*.* goto nocd
set path=%path%;X:\FreeDOS\Setup\ODIN
echo CDROM with ODIN found!
ctmouse >NUL
cdd X:\
setup.bat
rem the following should never have to happen
goto end

:livecd
set dosdir=x:\fdos
set path=%dosdir%\bin;X:\FreeDOS\Setup\ODIN
if exist %dosdir%\vim set vim=%dosdir%\vim\vim70
set helppath=%dosdir%\help
set nlspath=%dosdir%\nls
set blaster=A220 I5 D1 H5 P330
if "%config%"=="3" set config=3
if "%config%"=="4" set config=3
a:\freedos\xmssize 5 > NUL
set xms=%errorlevel%
if errorlevel 31 set xms=30
if not "%xms%"=="0" a:\driver\devload /H /QQ A:\DRIVER\CDRCACHE.SYS FDCD0000 CDRCACH0 %xms%000
if not "%xms%"=="0" A:\DRIVER\SHSUCDX.COM /QQ /R /D:CDRCACH0 /L:X
if "%xms%"=="0" A:\DRIVER\SHSUCDX.COM /QQ /R /D:FDCD0000 /L:X
if not exist FDCD0000 goto nocd
if exist %dosdir%\watcom\setvars.bat call %dosdir%\watcom\setvars.bat
a:\freedos\xmssize 50 > NUL
set xms=%errorlevel%
set RD=Z:
if "%xms%"=="0" set RD=C:
if not exist X:\FDOS\BIN\SHSURDRV.EXE goto nocd
if not "%xms%"=="0" SHSURDRV /QQ %xms%M,$RAMDISK,Z
if not "%xms%"=="0" if errorlevel 255 echo Ramdisk not loaded.
if not "%xms%"=="0" if errorlevel 255 set RD=C:
if "%config%"=="3" md %rd%\tmp
if "%config%"=="3" set tmp=%rd%\tmp
if "%config%"=="5" set tmp=c:\tmp
if "%config%"=="3" set temp=%rd%\tmp
if "%config%"=="5" set temp=c:\tmp
if "%config%"=="5" set config=
alias ls=ls --color=always
lh display CON=(EGA,,1)
mode con cp prep=((858) %dosdir%\bin\EGA.CPX)
mode con cp sel=858
ctmouse
a:\freedos\xmssize 10 > NUL
set xms=%errorlevel%
if errorlevel 31 set xms=30
if not "%errorlevel%"=="0" LH lbacache %xms%000 TUNS
a:\freedos\xmssize 99 > NUL
set xms=%errorlevel%
rem ?if exist c:\start\dosstart.bat call c:\start\dosstart.bat
cls
echo Welcome to the FreeDOS LiveCD.
echo.
echo Please type HELP to learn about commands.
echo.
echo Type menu to launch programs such as MPXPlay and VIM.
echo.
goto end
:nocd
echo There is no CDROM, or the wrong CD-ROM!
goto end
:safemode
echo.
localize 0.1 @@@ Welcome to the command prompt. No drivers were loaded.
echo.
:END
