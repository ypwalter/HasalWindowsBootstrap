REM Author: Walter Chen
REM Version: 0.0.1

REM Assuming that you already git pull all the files, we can use curl from the repository
REM Print out the time we started this script.
@echo off
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j
set ldt=%ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2% %ldt:~8,2%:%ldt:~10,2%:%ldt:~12,6%
echo [INFO] Current date and time [%ldt%]

::::::::::::::::::::
::  Prerequisite  ::
::::::::::::::::::::

REM Checking Administrator Privilege

REM If in appveyor, skip download and installation.
IF /i "%APPVEYOR%"=="True" goto NoAdmin_CI

AT > NUL
IF %ERRORLEVEL% EQU 0 (
    ECHO [INFO] You are Administrator and able to run this script.
) ELSE (
    ECHO [FAIL] You are NOT Administrator. Please rerun with Administrator privilege.
    PING 127.0.0.1 > NUL 2>&1
    EXIT /B 1
)

:NoAdmin_CI
IF "%APPVEYOR%"=="True" (
    ECHO [INFO] Skipping checking of Administrator privilege in CI
)

::::::::::::::::::::
::  Installation  ::
::::::::::::::::::::

REM Checking and Installing 7zip

REM If in appveyor, skip download and installation.
IF /i "%APPVEYOR%"=="True" goto 7zip_CI

REM Trying to download and install 7zip
where 7z.exe >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    ECHO [INFO] You already have 7Zip in windows system.
) ELSE (
    ECHO [INFO] Downloading 7Zip.
    thirdParty\curl -kLO http://www.7-zip.org/a/7z1604.exe
    ECHO [INFO] Installing 7Zip.
    7z1604.exe /S
    SETX PATH "C:\Program Files\7-Zip;C:\Program Files (x86)\7-Zip;%PATH%" /m
    SET "PATH=C:\Program Files\7-Zip;C:\Program Files (x86)\7-Zip;%PATH%"
)

:7zip_CI
IF "%APPVEYOR%"=="True" (
    ECHO [INFO] Skipping checking of 7zip in CI
    SET "PATH=C:\Program Files\7-Zip;%PATH%"
)


REM Installing ffmpeg

ECHO [INFO] Downloading FFMPEG.
thirdParty\curl -kLO https://ffmpeg.zeranoe.com/builds/win32/static/ffmpeg-20160527-git-d970f7b-win32-static.7z
7z x ffmpeg-20160527-git-d970f7b-win32-static.7z
ECHO [INFO] Installing FFMPEG.
SETX PATH "%CD%\ffmpeg-20160527-git-d970f7b-win32-static\bin\;%PATH%" /m
PATH=%CD%\ffmpeg-20160527-git-d970f7b-win32-static\bin\;%PATH%


REM Installing Sikuli
ECHO [INFO] Downloading SikuliX 1.1.0
thirdParty\curl -kLO https://launchpad.net/sikuli/sikulix/1.1.0/+download/sikulixsetup-1.1.0.jar
ECHO [INFO] Installing SikuliX 1.1.0
java -jar sikulixsetup-1.1.0.jar options 1.1 2
copy runsikuli* thirdParty\
copy sikuli*.jar thirdParty\
@echo on


REM Installing Miniconda

REM If in appveyor, skip download and installation
IF /i "%APPVEYOR%"=="True" goto SkipConda_CI

where conda.exe >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    ECHO [INFO] You already have conda in windows system.
) ELSE (
    ECHO [INFO] Downloading Miniconda.
    thirdParty\curl -kLO https://repo.continuum.io/miniconda/Miniconda2-latest-Windows-x86.exe
    ECHO [INFO] Installing Miniconda.
    Miniconda2-latest-Windows-x86.exe /InstallationType=JustMe /RegisterPython=0 /S /D=C:\Miniconda2\
    SETX PATH "C:\Miniconda2\;C:\Miniconda2\Scripts\;%PATH%" /m
    SET "PATH=C:\Miniconda2\Scripts\;C:\Miniconda2\;%PATH%"
)

SkipConda_CI:
IF "%APPVEYOR%"=="True" (
    ECHO [INFO] Skipping checking of conda in CI
    "SET PATH=%MINICONDA%;%MINICONDA%\\Scripts;%PATH%"
)


REM Configuring Miniconda and Virtualenv
conda config --set always_yes yes --set changeps1 no
conda install psutil
ECHO [INFO] Creating Miniconda virtualenv (It might take some time to finish.)
conda create -q -n hasal-env python=2.7 numpy scipy nose pywin32 pip

::::::::::::::::::::
::    Browsers    ::
::::::::::::::::::::

REM If in appveyor, skip download and installation
IF /i "%APPVEYOR%"=="True" goto SkipBrowser_CI

REM Installing firefox
ECHO [INFO] Downloading Firefox.
thirdParty\curl -kLO https://ftp.mozilla.org/pub/firefox/releases/49.0.1/win32/zh-TW/Firefox%%20Setup%%2049.0.1.exe
ECHO [INFO] Installing Firefox.
"Firefox%%20Setup%%2049.0.1.exe" -ms -ma
SETX PATH "C:\Program Files\Mozilla Firefox;C:\Program Files (x86)\Mozilla Firefox;%PATH%" /m
SET "PATH=C:\Program Files\Mozilla Firefox;C:\Program Files (x86)\Mozilla Firefox;%PATH%"
    
REM Installing chrome
ECHO [INFO] Downloading Chrome.
curl -kLO http://dl.google.com/chrome/install/googlechromestandaloneenterprise.msi
ECHO [INFO] Installing Chrome.
msiexec /i "googlechromestandaloneenterprise.msi" /qn /quiet /norestart
SETX PATH "C:\Program Files\Google\Chrome\Application\;C:\Program Files (x86)\Google\Chrome\Application\;%PATH%" /m
SET "PATH=C:\Program Files\Google\Chrome\Application\;C:\Program Files (x86)\Google\Chrome\Application\;%PATH%"

SkipBrowser_CI:
IF "%APPVEYOR%"=="True" (
    ECHO [INFO] Skipping installation of browser in CI
)

::::::::::::::::::::
::  Hasal  Setup  ::
::::::::::::::::::::

IF "%APPVEYOR%"=="True" (
    ECHO [INFO] Setup in virtualenv
    activate hasal-env
    pip install coverage mitmproxy
    pip install thirdParty\opencv_python-2.4.13-cp27-cp27m-win32.whl
    python setup.py install
) ELSE (
    REM Installing mitmproxy & opencv2 & Hasal
    activate hasal-env & pip install mitmproxy thirdParty\opencv_python-2.4.13-cp27-cp27m-win32.whl & certutil -p "" thirdParty\mitmproxy-ca-cert.p12 & python setup.py install & python scripts\cv2_checker.py
)

::::::::::::::::::::
::    Finished    ::
::::::::::::::::::::

REM Bootstrap done
