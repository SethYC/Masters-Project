# -*- coding: utf-8 -*-
"""
Script to be used on a PC in a rat colony room to play the bird chirping audio intermittently for 5 hours when specified.

Created on Fri Sep  9 17:58:50 2022

@author: seth.campbell
"""
#path to sound file
path = '/home/seth/Downloads/foo2.wav'
path2 = '/home/seth/Downloads/The sound of the night_ cicadas and nocturnal birds.mp3'

#import libraries
import pygame

pygame.init()
chirp = pygame.mixer.music
chirp.load(path2) #init music stream 

#play audio
chirp.play() #start music stream playback
