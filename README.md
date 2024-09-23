# Lithium Analyser tool

## About
This is a processing pipeline built in MATLAB designed to extract regional/tissue/brain information from lithium images without upsampling or smoothing the original lithium image. 
This was designed and created by Dr Gerard Hall & Dr David Cousins for the R-LINK project. It was created and developed by Gerard Hall, so please go easy and for technical issues and questions please email me (email below). 

## Requirments
The pipeline is designed to be ran in MATLAB_2024a or later. It requires you to have DCIM2NII setup in your MATLAB folder (link here: https://github.com/xiangruili/dicm2nii/tree/master). You will have to provide the location of your DCIM2NII folder when inputing pathways later on. 

Also it is required that you freesufer your Proton T1w image (https://surfer.nmr.mgh.harvard.edu), you don't need to FreeSurfer your Lithium T1w image if you have one. 

## How to run

### First Step, launch the App 

![Screenshot 2024-09-23 at 14 28 02](https://github.com/user-attachments/assets/fedcda28-2a7a-49c9-b590-a12328a92e82)

The pipeline is designed to be ran in **one** of **two** ways: 

### I have a Proton T1w image (FreeSurfered), Lithium Data image **AND** a Lithium T1w image (aligned to the Lithium Data image)

<img src="https://github.com/user-attachments/assets/adcc5842-28b6-4ede-9300-253a0ec3c87f" width="200" height="300">


### I have a Proton T1w image (FreeSurfered), Lithium Data image **I DON'T** have a Lithium T1w image 




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
