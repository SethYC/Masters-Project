# -*- coding: utf-8 -*-
"""
Script to be used on a PC in a rat colony room to play the bird chirping audio for a specified duration
(duration_hr) when ran. As the simple version, this plays an already modified mp3 track that has many periods of silence
between short segments of bird chirping audio, instead of mimicking this with a shorter mp3 track of just bird chirping
audio.

Created on Fri Sep 27
@author: Seth Campbell
"""

#init constants/parameters 
duration_hr = .05 #hours
#path = '/home/seth/Downloads/Western Wood-Pewee (Consolidation).mp3'
path = r'C:\Users\seth.campbell\OneDrive - University of Lethbridge\Documents\Masters\Thesis\Experiment 2\Western Wood Pewee (no voice).mp3'

#import libraries
import pygame
import time
from datetime import datetime

duration_s = duration_hr*60*60 #convert hours to seconds
start_t = datetime.now()

#audio setup & start
pygame.init()
chirp = pygame.mixer.music
chirp.load(path) #init music stream 
chirp.play(loops=-1) #start infinite loop music stream 

while True:
    time.sleep(10)
    
    #calc elapsed time and if past duration_hr, end program
    elapsed_t = (datetime.now()-start_t).total_seconds()
    if elapsed_t >= duration_s:
        print("time has elapsed")
        chirp.stop()
        break