# STAR-Fusion v1.0.1

## What does this app do?
Runs the STAR-Fusion docker image

## What inputs are required for this app to run?
* A 'Chimeric.out.junction' file, produced by STAR-Aligner
* STAR genome resource - from https://data.broadinstitute.org/Trinity/CTAT_RESOURCE_LIB/
* The DNA Nexus file ID of a saved STAR-Fusion Docker image

## How does this app work?
* Downloads and unzips/untars the STAR genome resource; downloads fastq's
* Runs the saved STAR-Fusion docker using default settings
* Production versions of this app will need to point to docker image on DNAnexus to ensure that the same version is run each time


## What does this app output
* All files generated in the STAR-Fusion output folder

## Notes
* This app is not ready for production use

## This app was made by East GLH
