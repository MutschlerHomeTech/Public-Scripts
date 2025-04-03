##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : Ping a host and log the results
#
# VERSION  : 1    (Initial release)
##########################################

@echo off

set /p host=host Address:
set logfile=Log_%host%.log

echo Target Host = %host% >%logfile%
for /f "tokens=*" %%A in ('ping %host% -n 1 ') do (echo %%A>>%logfile% && GOTO Ping)
:Ping
for /f "tokens=* skip=2" %%A in ('ping %host% -n 1 ') do (
    echo %date% %time:~0,2%:%time:~3,2%:%time:~6,2% %%A>>%logfile%
    echo %date% %time:~0,2%:%time:~3,2%:%time:~6,2% %%A
    timeout 1 >NUL
    GOTO Ping)