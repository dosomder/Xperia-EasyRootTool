@echo off
SETLOCAL EnableDelayedExpansion

echo.
echo ==============================================
echo =                                            =
echo =             Easy Root Tool v12             =
echo =      Supports various Xperia devices       =
echo =            created by zxz0O0               =
echo =                                            =
echo =     http://forum.xda-developers.com/       =
echo =        showthread.php?p=53448680           =
echo =                                            =
echo =       Many thanks to:                      =
echo =       - ^[NUT^]                              =
echo =       - geohot                             =
echo =       - MohammadAG                         =
echo =       - cubeundcube                        =
echo =       - nhnt11                             =
echo =       - xsacha                             =
echo =                                            =
echo ==============================================
echo.

cd files
set /a DLCount=0
set ANDROID_SERIAL=

if exist libexploit.so goto DevWait
if exist tr.apk goto FileCheck
echo =============================================
echo tr.apk not found. Trying to download from
echo https://towelroot.com/tr.apk
echo =============================================

curl -# -O https://towelroot.com/tr.apk
echo.
if exist tr.apk goto FileCheck

echo =============================================
echo Error downloading tr.apk with curl
echo Please download towelroot from https://towelroot.com
echo and save it as tr.apk in folder files/
echo.
echo If you still have problems, please disable
echo your Antivirus and try again
echo =============================================
pause
echo.
if not exist tr.apk (
	echo Error: tr.apk not found. Aborting...
	pause
	exit
)

:FileCheck

for %%A in (tr.apk) do set size=%%~zA
if %size% lss 1000 (
	echo =============================================
	echo Error: tr.apk seems not valid
	echo Please try again
	echo.
	echo Make sure your Antivirus is disabled
	echo =============================================
	del tr.apk
	pause
	exit
)

echo =============================================
echo Extracting libexploit.so using 7z
echo =============================================
7za e tr.apk lib/armeabi/libexploit.so >nul 2>&1
if not exist libexploit.so (
	echo Error extracting libexploit.so from tr.apk
	pause
	exit
)
echo OK!
del tr.apk
echo.

:DevWait
adb kill-server
adb start-server

echo =============================================
echo Waiting for Device, connect USB cable now...
echo.
echo Make sure that you authorize the connection
echo if you get any message on the phone
echo =============================================
adb wait-for-device >nul 2>&1
echo Device found!
for /f "delims=" %%i in ('adb devices') do (set /a CDevices+=1)
if %CDevices% gtr 2 (
	echo More than one device connected.
) else (
	goto GetVars
)
set availDevices= 
set /a CavailDevices=0
for /f "delims=" %%i in ('adb devices') do (
	set CurDev=%%i
	echo !CurDev! | findstr /I /l "^List of dev.*" >nul 2>&1
	if "!ERRORLEVEL!" == "1" (
		echo !CurDev! | findstr /I "^emulator" >nul 2>&1
		if "!ERRORLEVEL!" == "1" (
			for /f "tokens=1" %%i in ("!curDev!") do (
				set availDevices=!availDevices! %%i
				set /a CavailDevices+=1
			)
		)
	)
)

if "%CavailDevices%" == "1" (
	for %%i in (%availDevices%) do ( set ANDROID_SERIAL=%%i)
	echo Using device %ANDROID_SERIAL% since other is emulator..
	goto GetVars
)

:DevChoosing
echo.
echo Please choose the connected device you would
echo like to root. You can check under:
echo Settings ^=^> About phone ^=^> Status ^=^> Serial number
echo.
echo Available devices are:
set /a CDevices=0
for %%i in (%availDevices%) do (
set /a CDevices+=1
echo !CDevices!. %%i
)
echo.
set /p DevChosen=Please choose device [1 - %CDevices%]:
set NotNumeric=
for /f "delims=0123456789" %%i in ("%DevChosen%") do ( set NotNumeric=%%i)
if defined NotNumeric (
	goto DevChoosing
)
echo.
for /f "tokens=%DevChosen%" %%i in ("%availDevices%") do ( set ANDROID_SERIAL=%%i)
echo Connecting to device %ANDROID_SERIAL%

:GetVars
echo.
echo =============================================
echo Getting device variables
echo =============================================
set product_name=
for /f "delims=" %%i in ('adb shell "getprop ro.build.product"') do ( set product_name=%%i)
echo Device model is %product_name%
for /f "delims=" %%i in ('adb shell "getprop ro.build.id"') do ( set firmware=%%i)
echo Firmware is %firmware%

for /f "delims=" %%i in ('adb shell "cat /proc/version"') do ( set "kernelver=%%i")
set /a splitlength=0
for %%i in (!kernelver!) do (
	set /a splitlength+=1
	set "year=%%i"
)
if %year% lss 2014 (
	goto SendFiles
)
if %year% gtr 2014 (
	goto ShowWarning
)
set /a current=0
set /a splitlength-=3
for %%i in (!kernelver!) do (
	set /a current+=1
	if !current! equ !splitlength! (
		set "month=%%i"
	)
)

set /a current=0
for %%i in (Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec) do (
	set /a current+=1
	if "!month!" == "%%i" (
		set /a buildmonth=!current!
	)
)

if %buildmonth% gtr 5 (
	goto ShowWarning
)
goto SendFiles
:ShowWarning
echo.
echo WARNING: The kernel of your device was built after May 2014.
echo It's highly likely that rooting will fail because the exploit was patched
echo Try flashing an older kernel
echo.
echo If you still want to try, press any key to continue
pause


:SendFiles
echo.
echo =============================================
echo Sending files
echo =============================================

adb push zxz.sh /data/local/tmp/zxz.sh
adb push busybox /data/local/tmp
adb push installmount.sh /data/local/tmp
adb push writekmem /data/local/tmp
adb push findricaddr /data/local/tmp
adb shell "chmod 777 /data/local/tmp/zxz.sh"
adb shell "chmod 777 /data/local/tmp/installmount.sh"
adb shell "chmod 777 /data/local/tmp/writekmem"
adb shell "chmod 777 /data/local/tmp/findricaddr"
adb shell "chmod 777 /data/local/tmp/busybox"

echo.
echo Copying kernel module...
adb push "wp_mod.ko" /data/local/tmp/wp_mod.ko
adb push "kernelmodule_patch.sh" /data/local/tmp/kernelmodule_patch.sh
adb shell "chmod 777 /data/local/tmp/kernelmodule_patch.sh"
adb push "modulecrcpatch" /data/local/tmp/modulecrcpatch
adb shell "chmod 777 /data/local/tmp/modulecrcpatch"
adb shell "/data/local/tmp/kernelmodule_patch.sh"

echo.
echo =============================================
echo Loading towelzxperia
echo =============================================

adb push towelzxperia_ert /data/local/tmp
adb push libexploit.so /data/local/tmp
adb shell "chmod 777 /data/local/tmp/towelzxperia_ert"

echo =============================================
echo.
echo Waiting for towelzxperia to exploit...
echo.
adb shell "/data/local/tmp/towelzxperia_ert"
echo done

echo.
echo Checking if device is rooted...
ping 1.1.1.1 -n 1 -w 1000 > nul
rem adb wait-for-device
set isRooted=""
for /f "delims=" %%i in ('adb shell "su -c ls -l"') do (set isRooted=%%i)
if "%isRooted%" == "/system/bin/sh: su: not found" goto NoRoot
if "%isRooted%" == """" goto NoRoot
goto RootOK
:NoRoot
echo Error: device not rooted
pause
exit

:RootOK
echo.
echo Device rooted.

echo.
echo =============================================
echo Checking for Sony RIC
echo =============================================
for /f "delims=" %%i in ('adb shell "su -c /data/local/tmp/busybox grep sony_ric/enable /init*.rc | /data/local/tmp/busybox wc -l"') do (set SONYRIC=%%i)
if "%SONYRIC%" == "1" (
	echo Sony RIC Service found.
	echo Installing RIC kill script installmount.sh...
	ping 1.1.1.1 -n 1 -w 1000 > nul
	adb wait-for-device
	adb shell "su -c /data/local/tmp/installmount.sh"
) else (
	echo No Sony RIC Service found.
)
:Finish
echo.
echo Done. You can now unplug your device.
echo Enjoy root!
echo =============================================

adb shell "rm /data/local/tmp/zxz.sh"

adb shell "rm /data/local/tmp/kernelmodule_patch.sh"
adb shell "rm /data/local/tmp/findricaddr"

adb shell "rm /data/local/tmp/installmount.sh"
adb shell "rm /data/local/tmp/towelzxperia_ert"
adb shell "rm /data/local/tmp/libzxploit.so"
adb shell "rm /data/local/tmp/libexploit.so"
adb kill-server

echo.
echo What to do next?
echo - Donate to the people involved
echo - Install SuperSU by Chainfire
echo - Install dualrecovery by ^[NUT^]
echo - Backup TA partition
echo.
pause