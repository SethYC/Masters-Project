#Automate the set up and saving of videos for any number of rats based on a 'recording info.txt' file for my thesis experiment
#note: utlizies another bash script - camera_setup.sh
#
#Seth Campbell - July 24, 2021

file="/home/main/seth/recording info.txt" #file to get first date of recording for a cohort and rat ids
#new_location=/home/main/seth/nas/Seth #where to save video files, nas1 version
new_location=/home/main/seth/nas2/Seth_temp #nas2 version

while IFS= read line
do
	info_array+=($line)
done <"$file"
echo file contents: ${info_array[@]}


#loop through contents of info_array (i.e. first line is the date, then others are rat ids)
for i in ${!info_array[@]}; do
	#echo ${info_array[$i]}
	
	#if 1st line of file, set as cohort start date
	if [ $i = 0 ] #based on https://ryanstutorials.net/bash-scripting-tutorial/bash-if-statements.php
	then
		cohort_start=${info_array[$i]}
		
		y=$(date +%Y)
		m=$(date +%m)
		d=$(date +%d)
		let day_num=($(date +%s -d $y$m$d)-$(date +%s -d $cohort_start))/86400+1 #based on https://stackoverflow.com/questions/4946785/how-to-find-the-difference-in-days-between-two-dates
		echo day_num: $day_num
		if [ $day_num -gt 3 ] #3 days of baseline
		then
			if [ $day_num -gt 17 ] #past 14 days is the probe trial (14+5 baseline=19)
			then
				let day_num=01
				day_type='Probe' 		
			else
				let day_num=day_num-3 
				day_type='Training'
			fi
		else
			day_type='Baseline' 
		fi
		
		echo type: $day_type
		printf -v day_num "%02d" $day_num
		echo day: $day_num
	fi

	#else for each rat id,  start camera setup, close spinview after user prompt, then rename/move files
	if [ $i != 0 ]
	then
		rat_id=${info_array[$i]}
		bash /home/main/seth/camera_setup.sh #set up camera and do a recording

		#loop till the user confirms to move on to the next recording
		while :  ; do #while loop based on https://linuxhint.com/bash_wait_keypress/
		echo save video?
		read -n 3 k <&1
		
		if [[ $k = yes ]] ; then
			break
		else
			printf "\nType 'yes' to save videos and continue to next recording\n"
		fi
		done
		
		xdotool mousemove 1904 46 #go to window close button
		xdotool click 1
		#killall SpinView_QT #forces spinview to close, which stops it from hogging RAM for the next recording!
		
		printf "\n\nCopying files:"
		printf "\nCamera 1: "
		cd /ssd1
		file_name=$(ls -t *.avi | head -n1) #finds most recent file, from https://stackoverflow.com/questions/1015678/get-most-recent-file-in-a-directory-on-linux/23034261
		echo found $file_name
		#echo -p $new_location/practise_recording/${rat_id}/$(date +%F)_day$day_num/
		mkdir -p $new_location/Thesis\ recordings/rat${rat_id}/$(date +%F)-$day_type\_day$day_num/ #make a file for the day, this line based on https://stackoverflow.com/questions/547719/is-there-a-way-to-make-mv-create-the-directory-to-be-moved-to-if-it-doesnt-exis
		#cp $file_name $_rat${rat_id}_day${day_num}_cam1.avi & #note: $_ is the last argument of the previous command, thus the file path including the newly created date file
		cp $file_name $new_location/Thesis\ recordings/rat${rat_id}/$(date +%F)-$day_type\_day$day_num/rat${rat_id}_${day_type}_day${day_num}_cam1.avi &
		#mv -i $file_name /ssd1/${rat_id}_day${day_num}_cam1.avi 
		#mv -i $file_name $new_location/$(date +%F)/${day_num}_cam1.avi
		echo renamed to: rat${rat_id}_${day_type}_day${day_num}_cam1.avi
		
		printf "Camera 2: "
		cd /ssd2
		file_name=$(ls -t *.avi | head -n1) #finds most recent file, from https://stackoverflow.com/questions/1015678/get-most-recent-file-in-a-directory-on-linux/23034261
		echo found $file_name
		mkdir -p $new_location/Thesis\ recordings/rat${rat_id}/$(date +%F)-$day_type\_day$day_num/ #make a file for the day, this line based on https://stackoverflow.com/questions/547719/is-there-a-way-to-make-mv-create-the-directory-to-be-moved-to-if-it-doesnt-exis
		#cp $file_name $_rat${rat_id}_day${day_num}_cam2.avi & #note: $_ is the last argument of the previous command, thus the file path including the newly created date file
		cp $file_name $new_location/Thesis\ recordings/rat${rat_id}/$(date +%F)-$day_type\_day$day_num/rat${rat_id}_${day_type}_day${day_num}_cam2.avi &
		#mv -i $file_name $new_location/$(date +%F)/${day_num}_cam1.avi
		#mv -i $file_name /ssd2/${rat_id}_day${day_num}_cam2.avi 
		echo renamed to: rat${rat_id}_${day_type}_day${day_num}_cam2.avi
	fi
done
