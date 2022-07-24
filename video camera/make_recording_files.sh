#Make all folders for recording data based on starting date supplied in "recording info.txt". 
#Specifically, the 1st line of it should be the data in yyyymmdd format, 2nd line and on are the 
#rat #'s and ids with a "_" inbetween (e.g. '1_8401' for rat 1, whose id is 8401). 
#
#Output is a folder of folders automatically named based on the date. e.g. if the first day of 
#baseline recording was June 21, 2022, then 3 days later is the 1st day of training, which would
#have a folder named "2022-06-24-Training_day01".
#
#An example of a final file path created: "your selected directory"/thesis recordings/rat1_8401/2022-06-21-Baseline_day01/post-task_sleep
#
#Seth Campbell - created: November 19, 2021

#read info from file to get first date of recording for a cohort, and rat ids
file="/home/main/seth/recording info.txt" #path to file with start date and rat info
#new_location=/home/main/seth/nas/Seth #where to create new set of folders, nas1 version
new_location=/home/main/seth/nas2/Seth_temp #nas2 version


while IFS= read line
do
	#echo "$line"
	info_array+=($line)
done <"$file"
echo file contents: ${info_array[@]}

#loop through contents of info_array (i.e. first line is the date, then others are rat ids)
for i in ${!info_array[@]}; do
	#echo ${info_array[$i]}
	
	#if 1st line of file, use this as cohorot start date
	if [ $i = 0 ] #based on https://ryanstutorials.net/bash-scripting-tutorial/bash-if-statements.php
	then
		cohort_start=${info_array[$i]} #starting date for the cohort, used in calculations
		
		y=$(date +%Y) #current year
		m=$(date +%m) #current month
		d=$(date +%d) #current day
		let day_num=($(date +%s -d $y$m$d)-$(date +%s -d $cohort_start))/86400+1 #based on https://stackoverflow.com/questions/4946785/how-to-find-the-difference-in-days-between-two-dates
		
	fi
	
	if [ $i != 0 ] #for all other lines after the 1st one (i.e. rat ids), make a folder system
	then
		rat_id=${info_array[$i]} #rat id from the 2nd and on lines of "recording info.txt"
		
		day_num=0
		#loop through all possible days of recording and make baseline directories
		for i in {1..3}
		do	
			let day_num=i
			printf -v day_num "%02d" $day_num
			#echo $i $day_num 
			
			#compute the dates to be in the folder name based on the cohort start date plus the number of days into the recording (day_num)
			let folder_date=$(date +%s -d $cohort_start) #convert cohort start date
			#echo $folder_date
			let folder_date=(86400*10#$day_num-1)+folder_date #compute future date based on adding the day_num (in seconds)
			#note: 10# part is needed to stop interpretting day_num as a octal number which caused errors when on the 8th or 9th day which don't exist as digits in octal (thus 08 and 09 used to cause errors until you force base 10 interpretation), see https://stackoverflow.com/questions/12821715/convert-string-into-integer-in-bash-script-leading-zero-number-error/12821845#12821845 & https://stackoverflow.com/questions/21049822/value-too-great-for-base-error-token-is-09
			#echo $folder_date
			folder_date=$(date -d @${folder_date} +"%F") #based on: https://stackoverflow.com/questions/13422743/convert-a-time-span-in-seconds-to-formatted-time-in-shell
			#echo $folder_date
			
			#make a file for the day, based on https://stackoverflow.com/questions/547719/is-there-a-way-to-make-mv-create-the-directory-to-be-moved-to-if-it-doesnt-exis
			mkdir -p $new_location/Thesis\ recordings/rat${rat_id}/$folder_date-Baseline_day$day_num/pre-task_sleep/ 
			#mkdir -p $new_location/Thesis\ recordings/rat${rat_id}/$folder_date-Baseline_day$day_num/task/
			mkdir -p $new_location/Thesis\ recordings/rat${rat_id}/$folder_date-Baseline_day$day_num/post-task_sleep/ 
		done
		
		#loop for training days
		for i in {1..14}
		do	
			let day_num=i
			printf -v day_num "%02d" $day_num
			#echo $i $day_num 
			
			#compute the dates to be in the folder name based on the cohort start date plus the number of days into the recording (day_num)
			let folder_date=$(date +%s -d $cohort_start) #convert cohort start date to seconds
			#echo $folder_date
			let folder_date=(86400*10#$day_num-1)+folder_date #compute future date based on adding the day_num (in seconds)
			#echo $folder_date
			let folder_date=(86400*3)+folder_date #add 3 days to account for habituation that already happened
			folder_date=$(date -d @${folder_date} +"%F") #based on: https://stackoverflow.com/questions/13422743/convert-a-time-span-in-seconds-to-formatted-time-in-shell
			#echo $folder_date
			
			#make a file for the day, based on https://stackoverflow.com/questions/547719/is-there-a-way-to-make-mv-create-the-directory-to-be-moved-to-if-it-doesnt-exis
			mkdir -p $new_location/Thesis\ recordings/rat${rat_id}/$folder_date-Training_day$day_num/pre-task_sleep/ 
			mkdir -p $new_location/Thesis\ recordings/rat${rat_id}/$folder_date-Training_day$day_num/task/
			mkdir -p $new_location/Thesis\ recordings/rat${rat_id}/$folder_date-Training_day$day_num/post-task_sleep/ 
		done
		
		#for probe day	
		let day_num=1
		printf -v day_num "%02d" $day_num
		#echo $i $day_num 
			
		#compute the dates to be in the folder name based on the cohort start date plus the number of days into the recording (day_num)
		let folder_date=$(date +%s -d $cohort_start) #convert cohort start date to seconds
		#echo $folder_date
		let folder_date=(86400*10#$day_num-1)+folder_date #compute future date based on adding the day_num (in seconds)
		#echo $folder_date
		let folder_date=(86400*23)+folder_date #add 23 days to account for baseline, training and 6 days off that already happened
		folder_date=$(date -d @${folder_date} +"%F") #based on: https://stackoverflow.com/questions/13422743/convert-a-time-span-in-seconds-to-formatted-time-in-shell
		#echo $folder_date
			
		#make a file for the day, based on https://stackoverflow.com/questions/547719/is-there-a-way-to-make-mv-create-the-directory-to-be-moved-to-if-it-doesnt-exis
		mkdir -p $new_location/Thesis\ recordings/rat${rat_id}/$folder_date-Probe_day$day_num/pre-task_sleep/ 
		mkdir -p $new_location/Thesis\ recordings/rat${rat_id}/$folder_date-Probe_day$day_num/task/
		mkdir -p $new_location/Thesis\ recordings/rat${rat_id}/$folder_date-Probe_day$day_num/post-task_sleep/ 
	
	fi
done
