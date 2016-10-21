REM Author: Walter Chen
REM Version: 0.0.1

REM Assuming that you already git pull all the files, we can install curl from the repository
msiexec /i curl-7.46.0-win32-local.msi /quiet /qn /norestart /log curl.log

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

REM Checking Curl

REM Checking Git


::::::::::::::::::::
::  Installation  ::
::::::::::::::::::::

REM Installing 7zip

REM Installing Miniconda
curl -kLO https://repo.continuum.io/miniconda/Miniconda2-latest-Windows-x86.exe
Miniconda2-latest-Windows-x86.exe /InstallationType=JustMe /RegisterPython=0 /S /D=C:\Anaconda2\

REM Installing winpy32

REM Installing opencv2

REM Installing mitmproxy

REM Installing ffmpeg

REM Installing Sikuli


::::::::::::::::::::
::  Hasal  Setup  ::
::::::::::::::::::::

REM Creating virtualenv from conda

REM Installing numpy and scipy

REM Installing Hasal


::::::::::::::::::::
::    Checking    ::
::::::::::::::::::::

REM Checking CV2

REM Checking system packages


::::::::::::::::::::
::    Browsers    ::
::::::::::::::::::::

REM Installing chrome

REM Installing firefox


::::::::::::::::::::
::    Finished    ::
::::::::::::::::::::

REM Bootstrap done




