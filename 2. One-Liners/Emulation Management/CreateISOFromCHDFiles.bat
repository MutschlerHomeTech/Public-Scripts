for %%i in (*.chd) do (
chdman extractcd -i "%%i" -o "%%~ni.cue" -ob "%%~ni.iso"
del "%%~ni.cue"
) >> log