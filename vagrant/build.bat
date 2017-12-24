@echo OFF

set BOX_NAME=%1
set BOX_VERSION=%2
set VM_ID_FILE=%CD%\.vagrant\machines\default\virtualbox\id

if "%BOX_NAME%" == "" (
    set BOX_NAME=localhost/docker-webdev
    set BOX_VERSION=0
)

if "%BOX_VERSION%" == "" (
    echo Missing version number.
    exit /B 1
)

set BOX_OUTPUT=%BOX_NAME:/=-VAGRANTSLASH-%
set BOX_OUTPUT=%BOX_OUTPUT%-v%BOX_VERSION%.box
set BOX_NAME_AND_VERSION=%BOX_NAME%

if NOT "%BOX_VERSION%" == "0" (
    set BOX_NAME_AND_VERSION=%BOX_NAME_AND_VERSION%-v%BOX_VERSION%
)

if exist "%BOX_OUTPUT%" ( del %BOX_OUTPUT% )

vagrant destroy -f
vagrant up --provider virtualbox

if exist %VM_ID_FILE% (
    set /p VM_ID=<%VM_ID_FILE%
) else (
    echo Virtual machine not found
    exit /B 2
)

vagrant halt
vagrant package --base "%VM_ID%" --output "%BOX_OUTPUT%" --vagrantfile "Vagrantfile.provision"

set BOX_EXISTS=1
SETLOCAL ENABLEDELAYEDEXPANSION
set BOX_VERSION=0
FOR /F "tokens=* USEBACKQ" %%F IN (`vagrant box list ^| findstr /R /C:"^my/firsttest *\(virtualbox, %BOX_VERSION%\)$"`) DO (
    SET var=%%F
)

if "%var%" == "" (
    set BOX_EXISTS=0
)
ENDLOCAL & (
    set "BOX_EXISTS=%BOX_EXISTS%"
)

if "%BOX_EXISTS%" == "1" (
    vagrant box remove "%BOX_NAME_AND_VERSION%"
)
vagrant box add --name "%BOX_NAME_AND_VERSION%" --provider virtualbox "%BOX_OUTPUT%"
