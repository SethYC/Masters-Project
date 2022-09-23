# -*- coding: utf-8 -*-
"""
Script to be used on a PC in a rat colony room to play the bird chirping audio intermittently for 5 hours when specified.

Created on Fri Sep  9 17:58:50 2022

@author: seth.campbell
"""

#init constants/parameters 
path = '/home/seth/Downloads/foo2.wav' #path to sound file
path2 = '/home/seth/Downloads/The sound of the night_ cicadas and nocturnal birds.mp3'
duration_hr = 5 #hours
bin_dur = 10 #seconds
sound_on_ratio = 0.6 

#import libraries
import pygame
import time
from datetime import datetime

duration_s = duration_hr*60*60 #convert hours to seconds
start_t = datetime.now()

pygame.init()
chirp = pygame.mixer.music
chirp.load(path2) #init music stream 

#play audio
chirp.play(loops=-1) #start infinite loop music stream 

while True:
    time.sleep(bin_dur)
    #generate rand int from 0 to 1, if larger than sound_on_ration, then
    #stop audio, else play audio
    elapsed_t = (datetime.now()-start_t).total_seconds()
    if elapsed_t >= duration_s:
        print("time has elapsed")
        chirp.stop()
        break






