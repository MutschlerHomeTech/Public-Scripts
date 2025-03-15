##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : Message logged on users utilizing a system restart, but cancel the restart afterwards.
#
# VERSION  : 1    (Initial release)
##########################################

shutdown -r -t 600 -c "This system is restarting in 10 minutes to recover OS stability. Please logoff now to prevent data loss."
timeout /t 5
shutdown -a