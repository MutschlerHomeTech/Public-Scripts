##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : Create directories from a list of names
#
# VERSION  : 1    (Initial release)
##########################################

set list=\\192.168.1.41\Emulation\OrganizedRoms\directories.txt
set location=\\192.168.1.41\Emulation\OrganizedRoms


for /f "delims== tokens=1,2" %%G in (%list%) do (
    md "%location%\%%G"
    if errorlevel 1 (echo Error creating folder : %location%\%%G >> Error.txt)
)