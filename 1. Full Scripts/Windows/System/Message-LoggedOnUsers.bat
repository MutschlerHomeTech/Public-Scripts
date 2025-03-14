shutdown -r -t 600 -c "This system is restarting in 10 minutes to recover OS stability. Please logoff now to prevent data loss."
timeout /t 5
shutdown -a