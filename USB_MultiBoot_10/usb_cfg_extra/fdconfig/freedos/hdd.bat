@echo off
if x%1==x goto e
textinst.exe /SRC %1 /df install.dat /mono
CDD C:\
locate.com postinst.bat /O:&D /N /F:1 /G
if exist postinst.bat set path=%_CWD%;%_CWD%\bin;%path%
if exist postinst.bat postinst.bat 
if exist c:\fdconfig.sys goto o
md c:\temp
copy %comspec% c:\temp\command.com
echo shell=c:\temp\command.com c:\temp /P > c:\fdconfig.sys

:o
CDD -
for %%x in ( \kernel.sys kernel.sys ) do if exist %%x copy /y %%x c:\kernel.sys
cls
echo Some files not found. Aborting setup now..
:e