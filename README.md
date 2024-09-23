# Lithium Analyser tool

## About
This is a processing pipeline built in MATLAB designed to extract regional/tissue/brain information from lithium images without upsampling or smoothing the original lithium image. 
This was designed and created by Dr Gerard Hall & Dr David Cousins for the R-LINK project. It was created and developed by Gerard Hall, so please go easy and for technical issues and questions please email me (email below). 

## Requirments
The pipeline is designed to be ran in MATLAB_2024a or later. It requires you to have DCIM2NII setup in your MATLAB folder (https://github.com/xiangruili/dicm2nii/tree/master). You will have to provide the location of your DCIM2NII folder when inputing pathways later on. 

Also it is required that you freesufer your Proton T1w image (https://surfer.nmr.mgh.harvard.edu), you don't need to FreeSurfer your Lithium T1w image if you have one. 

## How to run

### First Step, launch the App 

![Screenshot 2024-09-23 at 14 28 02](https://github.com/user-attachments/assets/fedcda28-2a7a-49c9-b590-a12328a92e82)

The pipeline is designed to be ran in **one** of **two** ways: 

### Second Step, I have a Proton T1w image (FreeSurfered), Lithium Data image **AND** a Lithium T1w image (aligned to the Lithium Data image)

You need a simple text files each containing the pathways to:
* Patient ID, this should not contain a pathway (i.e. blissmr036)
* Pathway to Lithium images (i.e. Pathway/to/Lithium_Image.nii)
* Pathway to Lithium T1w images (i.e. Pathway/to/Lithium_T1w_Image.nii)
* Pathway to the Output FreeSurfer folder for the Proton T1w image (i.e. Pathway/to/FreeSufer_Folder (One folder above the mri folder)
* Pathway to the empty Output Folder (i.e. Pathway/to/empty/output_folder)
* Pathway to the DICM2NII folder (i.e. Pathway/to/xiangruili-dicm2nii-3fe1a27)  

** Note each line in the .txt lists, should be the SAME individual for every other .txt list ** 
  
#### Screenshot example below:
<img src="https://github.com/user-attachments/assets/adcc5842-28b6-4ede-9300-253a0ec3c87f" width="361" height="408">


### Second Step, I have a Proton T1w image (FreeSurfered), Lithium Data image **I DON'T** have a Lithium T1w image 

You need a simple text files each containing the pathways to:
* Patient ID, this should not contain a pathway (i.e. blissmr036)
* Pathway to Lithium images (i.e. Pathway/to/Lithium_Image.nii)
* Pathway to the Output FreeSurfer folder for the Proton T1w image (i.e. Pathway/to/FreeSufer_Folder (One folder above the mri folder)
* Pathway to the empty Output Folder (i.e. Pathway/to/empty/output_folder)
* Pathway to the DICM2NII folder (i.e. Pathway/to/xiangruili-dicm2nii-3fe1a27)  

** Note each line in the .txt lists, should be the SAME individual for every other .txt list ** 
  
#### Screenshot example below:
<img src="https://github.com/user-attachments/assets/2d24b374-ad80-4f14-b290-c7258fb8f4a5" width="361" height="408">

### Third Step, "Run pipeline" 

There maybe some QC pop-ups (Sorry they maybe annoying) of images and warnings in the console, don't worry about these for now (unless they stop the pipeline). Quality control .pngs will be output every step. I will updates these and make the pipeline run better once I get the chance in the future. 

## Output 

The output will be in the "<Output_Name>/Overall_Stats" Folder. There will be .csv's of each patient and information of each Lithium Voxel in the Lithium image (each will be given a unique look up number). It will output the value of the Lithium voxel in its signal and where is places in relation to tissue, regional or brain/non-brain boundarys (Atlas is based of the FreeSurfer aparc+aseg.mgz atlas). Now is the time for you to run your stats and analyse! You can also exlude what percentage voxels inside/outside regions or brain etc using your own freindly statistical package. I have also included mean weighted averaging (MWA) for brain/tissue/regional values also. 

## Citation
If using this pipeline please cite the following: 
Paper not out yet, will fill this in once we are published!! 

## Additional Stuff

Software Requirements: 
- MATLAB (2024a or later) (Make sure to download the folder for the pipeline into your local MATLAB folder)
- DIM2NII (https://github.com/xiangruili/dicm2nii/tree/master)
- FreeSurfered T1ws (https://surfer.nmr.mgh.harvard.edu)


## Contacts
Any questions please contact 
 - Gerard Hall (gerard.hall@newcastle.ac.uk) 
