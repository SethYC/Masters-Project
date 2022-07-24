#Automates the setup of Spinview for the double video camera setup.
#Heavily relies on coordinates of the monitor being the same (1920x1200).
#Requires xdotool program, can be installed via 'sudo apt install xdotool"
#
#Seth Campbell - July 17, 2021

#delcare constants
cam1_x=140
cam2_x=$cam1_x #same position in Spinview GUI horizontally
cam1_y=305
cam2_y=325 #2nd camera should be below the first

#spinview  #acts differently then simply clicking it, so doesn't work
xdotool mousemove 40 610 click 1 #click spinview icon in vertical taskbar
sleep 4

#note: monitor this was written on was 1920 pixels/units wide, 1200 pixels/units tall
#xdotool mousemove 1045 46 click 1 #maximize spinview window
xdotool search --class --onlyvisible Spinview windowActivate #activates the Spinview window for this script
sleep 0.5 #slight delay needed for next command to work 
#xdotool key super+Up #maximize window via keyboard shortcut (doesn't seem to work in this situation)
xdotool windowsize $(xdotool getactivewindow) 100% 100% #got from https://askubuntu.com/questions/384736/how-do-i-maximize-an-already-open-gnome-terminal-window-from-command-line


xdotool mousemove $cam1_x $cam1_y  
xdotool click 1 #click main camera in devices
sleep 5
xdotool mousemove $cam2_x $cam2_y 
xdotool click 1 #click secondary camera in devices

#start aquisition
xdotool mousemove 440 160 click 1 #main camera aquistion button
sleep 0.5 #slight delay needed based  on second window still loading
xdotool mousemove 440 1050 click 1 #secondary camera aquisiton button

#open recording window
xdotool mousemove 853 167 click 1 #red recording button

#set save location to ssd 1 for main camera
xdotool key "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" s s d 1

#set trigger mode off for main camera (for some reason the camera won't remember to start on 'off')
xdotool mousemove $cam1_x $cam1_y click 1 #reselect main camera
xdotool mousemove 250 610 click 1 key t r i g g e r space m o d e #enter the text "trigger mode' in the search box
xdotool mousemove 250 665 click 1 mousemove 250 645 
xdotool click 1 #set to on 

#set main camera video settings
xdotool mousemove 1100 370 click 1 #video button
xdotool mousemove 1250 405 click 1 #video recording type button
xdotool mousemove 1250 430 click 1 #select MJPG 
xdotool mousemove 1250 430 click 1 #"Use cmaera frame rate' button

#set trigger mode on for main camera
xdotool mousemove $cam1_x $cam1_y click 1 #reselect main camera
#xdotool mousemove 250 610 click 1 key t r i g g e r space m o d e #enter the text "trigger mode' in the search box
xdotool mousemove 250 665
#sleep 2 
#xdotoolclick 1 mousemove 250 680
xdotool click 1 #set to on 
sleep 1
xdotool mousemove 250 685
#sleep 2
xdotool click 1

#prime recording
xdotool mousemove 1400 820 click 1 #start button (note: doesn't actually start recording, trigger mode being off does)

#open recording window 2 (repeat above steps essentially)
xdotool mousemove 850 1050 click 1

#set save location to ssd 2 for secondary camera
xdotool key "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" "BackSpace" s s d 2

#set secondary camera video settings
xdotool mousemove 1100 370 click 1
xdotool mousemove 1250 405 click 1 
xdotool mousemove 1250 430 click 1
xdotool mousemove 1250 430 click 1

xdotool mousemove $cam2_x $cam2_y click 1 #select second camera
xdotool mousemove 250 665 click 1 mousemove 250 685 click 1 #set trigger back on before hitting record

#prime recording
xdotool mousemove 1400 820 
xdotool click 1

#place mouse on trigger mode to prepare for recording start
xdotool mousemove $cam1_x $cam1_y click 1 #click main camera in devices
xdotool mousemove 250 665 click 1 #trigger mode option
sleep 0.5
xdotool mousemove 250 640 #place mouse on top of "off' option
