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

#import libraries
import pygame
from datetime import datetime

duration_s = duration_hr*60*60 #convert hours to seconds
start_t = datetime.now()

pygame.init()
chirp = pygame.mixer.music
chirp.load(path2) #init music stream 

#play audio
chirp.play() #start music stream playback

# while True:
#     elapsed_t = (datetime.now()-start_t).total_seconds()








