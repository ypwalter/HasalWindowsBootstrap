REM Author: Walter Chen
REM Version: 0.0.1

REM Assuming that you already git pull all the files, we can use curl from the repository
REM Print out the time we started this script.
@echo off
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j
set ldt=%ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2% %ldt:~8,2%:%ldt:~10,2%:%ldt:~12,6%
echo [INFO] Current date and time [%ldt%]
@echo on

::::::::::::::::::::
::  Prerequisite  ::
::::::::::::::::::::

REM Checking Administrator Privilege
@echo off
AT > NUL
IF %ERRORLEVEL% EQU 0 (
    ECHO [INFO] You are Administrator and able to run this script.
) ELSE (
    ECHO [FAIL] You are NOT Administrator. Please rerun with Administrator privilege.
    PING 127.0.0.1 > NUL 2>&1
    EXIT /B 1
)
@echo on

REM Checking Java
@echo off
FOR /f %%j IN ("java.exe") DO (
    SET JAVA_HOME=%%~dp$PATH:j
)

IF %JAVA_HOME%.==. (
    ECHO [INFO] Downloading Java JDK 7u79.
    curl -L -O -H "Cookie:oraclelicense=accept-securebackup-cookie" -k "http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-windows-i586.exe"
    ECHO [INFO] Installing Java JDK 7u79.
    jdk-7u79-windows-i586.exe /s
) ELSE (
    ECHO [INFO] Java JDK exists in the environment.
    ECHO JAVA_HOME = %JAVA_HOME%
)
@echo on

::::::::::::::::::::
::  Installation  ::
::::::::::::::::::::

REM Installing 7zip
curl -kLO http://www.7-zip.org/a/7z1604.exe
7z1604.exe /S
SETX /M PATH C:\Program Files\7-Zip;^%PATH^%
PATH=C:\Program Files\7-Zip;%PATH%

REM Installing Miniconda
curl -kLO https://repo.continuum.io/miniconda/Miniconda2-latest-Windows-x86.exe
Miniconda2-latest-Windows-x86.exe /InstallationType=JustMe /RegisterPython=0 /S /D=C:\Miniconda2\
SETX /M PATH C:\Miniconda2\Scripts\;^%PATH^%
PATH=C:\Miniconda2\Scripts\;%PATH%
SETX /M PATH C:\Miniconda2\;^%PATH^%
PATH=C:\Miniconda2\%PATH%

REM Configuring Miniconda and Virtualenv
conda config --set always_yes yes --set changeps1 no
conda install psutil
conda create -q -n hasal-env python=2.7 numpy scipy nose
activate hasal-env

REM Installing winpy32
conda install pywin32

REM Installing mitmproxy
pip install mitmproxy

REM Installing opencv2
pip install opencv_python-2.4.13-cp27-cp27m-win32.whl

REM Installing ffmpeg
curl -kLO https://ffmpeg.zeranoe.com/builds/win32/static/ffmpeg-20160527-git-d970f7b-win32-static.7z
7z x ffmpeg-20160527-git-d970f7b-win32-static.7z
 
PATH=%CD%\ffmpeg-20160527-git-d970f7b-win32-static\bin\;%PATH%

REM Installing Sikuli
java -jar sikulixsetup-1.1.0.jar options 1.1 2
cp runsikuli* Hasal\thirdParty\
cp sikuli*.jar Hasal\thirdParty\

::::::::::::::::::::
::  Hasal  Setup  ::
::::::::::::::::::::

REM Installing Hasal (hasal-env virtualenv activated in advance)
python setup.py install

::::::::::::::::::::
::    Checking    ::
::::::::::::::::::::

REM Checking CV2
python scripts/cv2_checker.py

REM Checking system packages
python scripts/sys_pkg_checker.py


::::::::::::::::::::
::    Browsers    ::
::::::::::::::::::::

REM Installing chrome

REM Installing firefox


::::::::::::::::::::
::    Finished    ::
::::::::::::::::::::

REM Bootstrap done




