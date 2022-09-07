%Create a sleep struct for a single epoch based on current location. Used
%for just testing specific recordings before rats are officially in a group
%and begin a cohort recording. 

function generate_test_sleep_struct()

global epochs %declare as global to simplify later code
set_motion_thresh('yyy.ncs',-1)

%replicate epochs_from_motionless() function but without directory changing or loading a epochs file 
load('s1_motionless.mat')
epochs.tssleep1 = sleep;
epochs.tswake1 = wake;
epochs.motionthresh1 = threshold;

%replicate tone2epochs_2_room_ver() function but without directory changing components
[ts,s,~] = events_read('events.nev');
ix = strcmp(s,'pulse');
ix = bitor(ix, strcmp(s, 'control tone')); %new for my experiment, also look for tones called 'control tone'
ts = ts(ix) / 100; 
epochs.tone1 = [ts' ts'+10000];

sleep_struct('1E',-1,1) %just use '1E' as it uses default settings

end