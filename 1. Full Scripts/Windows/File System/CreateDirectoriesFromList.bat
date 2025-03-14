set list=\\192.168.1.41\Emulation\OrganizedRoms\directories.txt
set location=\\192.168.1.41\Emulation\OrganizedRoms


for /f "delims== tokens=1,2" %%G in (%list%) do (
    md "%location%\%%G"
    if errorlevel 1 (echo Error creating folder : %location%\%%G >> Error.txt)
)