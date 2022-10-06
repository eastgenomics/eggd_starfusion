# STAR-Fusion v1.0.1

## What does this app do?
Runs STAR-Fusion, a tool which identifies candidate fusion transcripts from RNA alignments. This app is specifically set up to process the 'Chimeric.out.junction' files produced by the earlier STAR-Aligner alignment step. It produces a file of candidate fusion regions.

## What inputs are required for this app to run?
* The DNA Nexus file ID of a 'Chimeric.out.junction' file, produced by STAR-Aligner
* The DNA Nexus file ID of a STAR genome resource - from https://data.broadinstitute.org/Trinity/CTAT_RESOURCE_LIB/
* The DNA Nexus file ID of a saved STAR-Fusion Docker image

## How does this app work?
* Downloads and unzips/untars the STAR genome resource
* Downloads the Chimeric.out.junction file
* Runs a saved STAR-Fusion Docker image using default settings
* Production versions of this app will need to point to a controlled Docker image in 'references' on DNAnexus to ensure that the same version is run each time


## What does this app output
* All files generated in the STAR-Fusion output folder

## Notes
* This app is not ready for production use

## This app was made by East GLH
