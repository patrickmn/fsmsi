@echo off
::::::
::
:: Failsafe MSI (FSMSI) -- activate the Windows Installer service in fail safe mode.
::
:: Version 1.0 -- April 3rd, 2009
:: http://patrickmylund.com/projects/fsmsi/
:: by Patrick Mylund - patrick@patrickmylund.com
::
:: Thanks to Said Doubi for the magic.
::
::::
::
:: Usage:
::   - Run fsmsi.cmd with elevated privileges (Run as administrator).
::     Run "fsmsi.cmd deactivate" to reverse the changes.
::
::::
::
:: Failsafe MSI (FSMSI) is released under the MIT License:
::
:: Copyright (c) 2009 Patrick Mylund
::
:: Permission is hereby granted, free of charge, to any person obtaining a copy
:: of this software and associated documentation files (the "Software"), to deal
:: in the Software without restriction, including without limitation the rights
:: to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
:: copies of the Software, and to permit persons to whom the Software is
:: furnished to do so, subject to the following conditions:
::
:: The above copyright notice and this permission notice shall be included in
:: all copies or substantial portions of the Software.
::
:: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
:: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
:: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
:: AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
:: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
:: OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
:: THE SOFTWARE.
::
::::::

set fsmsilog="%temp%\fsmsi.log"
echo FSMSI running: > %fsmsilog%
echo. >> %fsmsilog%

echo  * Adding MSI service for Fail Safe... >> %fsmsilog%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Minimal\MSIServer" /ve /t REG_SZ /f /d "Service"
if %errorlevel% neq 0 goto regfail
echo  * Adding MSI service for Fail Safe (with Networking)... >> %fsmsilog%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Network\MSIServer" /ve /t REG_SZ /f /d "Service"
if %errorlevel% neq 0 goto regfail
:: We do this check here because we're lazy and only want to get errorlevel 1
:: because of UAC in :deactivate below.
if [%1] == [deactivate] goto deactivate
echo  * Starting MSI service... >> %fsmsilog%
net start msiserver
if %errorlevel% equ 1 goto servicefail
echo  * Launching "Add/Remove Programs" control panel applet... >> %fsmsilog%
start appwiz.cpl
echo. >> %fsmsilog%
echo All done. >> %fsmsilog%
goto end

:deactivate
echo  * DEACTIVATE detected, reversing changes: >> %fsmsilog%
echo    * Stopping MSI service... >> %fsmsilog%
net stop msiserver
echo    * Removing MSI service for Fail Safe... >> %fsmsilog%
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Minimal\MSIServer" /ve /f
if %errorlevel% neq 0 goto regfail
echo    * Removing MSI service for Fail Safe (with Networking)... >> %fsmsilog%
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Network\MSIServer" /ve /f
if %errorlevel% neq 0 goto regfail
echo. >> %fsmsilog%
echo All done. >> %fsmsilog%
start notepad %fsmsilog%
goto end

:regfail
echo  - ERROR: Failed to add or delete service registry key. >> %fsmsilog%
goto elevationreminder

:servicefail
echo  - ERROR: Failed to start the Windows Installer service. >> %fsmsilog%
goto elevationreminder

:elevationreminder
echo. >> %fsmsilog%
echo Make sure you are running fsmsi.cmd with elevated privileges (Run as administrator). >> %fsmsilog%
start notepad %fsmsilog%
goto end

:end
