##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : Move files from one directory to another.
#
# VERSION  : 1    (Initial release)
##########################################

$current_videos = 'F:\Outplayed\Overwatch'
$new_videos = 'G:\Unedited'
Move-Item -Path $current_videos -Destination $new_videos -force