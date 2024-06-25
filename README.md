# Lithium Pipeline (Version 2)

## About
This is a processing pipeline designed to extract regional/tissue/brain information from lithium images without upsampling or smoothing the original lithium image. 
This was designed and created by Dr Gerard Hall & Dr David Cousins for the R-LINK project. 

## Requirments 
You first need three images (all in NIFTI format) in order to run: 
  - Lithium Image (Expecting this image to be coarse in resolution i.e. 15mmx15mmx20mm)
  - T1w Lithium Coil (A structural image that is in the same "space" as the lithium image for reference) 
  - T1w Proton Coil (A classic T1w image taken with a proton head coil)* 

*Secondly you will need to have the T1w Proton Coil FreeSurfered. Software link for FreeSurfer (https://surfer.nmr.mgh.harvard.edu). 
Please remeber to cite FreeSurfer when using their software. 

Software Requirements: 
- MATLAB (2024a or later) (Make sure to download the folder for the pipeline into your local MATLAB folder)

This is a current pipeline that is still in progress, in the upcoming months I will attempt to add:
  - Greater dilation of mask (Current mask is little too conservative)
  - 


## Contacts
Any questions please contact 
 - Gerard Hall (gerard.hall@newcastle.ac.uk) 
