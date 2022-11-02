# STAR-Fusion v1.0.1

## What does this app do?
Runs STAR-Fusion, a tool which identifies candidate fusion transcripts from RNA alignments. This app is specifically set up to process the 'Chimeric.out.junction' files produced by the earlier STAR-Aligner alignment step. It produces files of candidate fusion regions.

## What inputs are required for this app to run?
* The DNA Nexus file ID of a junction file, produced by STAR-Aligner
    * The file should be named in the format 'sample_name.chimeric.junction.out'
    * The file name is split on '.' and the first field used to name the output files
* The DNA Nexus file ID of a STAR genome resource, which should be a compressed '.tar.gz' file - from https://data.broadinstitute.org/Trinity/CTAT_RESOURCE_LIB/
* The DNA Nexus file ID of a saved STAR-Fusion Docker image, which should be a compressed '.tar.gz'

## How does this app work?
* Downloads and unzips/untars the STAR genome resource
* Downloads the sample_name.chimeric.out.junction file
* Loads and runs the STAR-Fusion Docker image using default settings
    * Production versions of this app will need to point to a controlled Docker image in 'references' on DNAnexus to ensure that the same version is run each time
* Prefixes output file names with the sample name
* Uploads the output files to DNA Nexus

## What does this app output?
* The app generates:
    * starfusion_predictions: the predictions file prefixed with the sample name (extracted from the '.chimeric.junction.out' file), and ending '.fusion_predictions.tsv'
    * starfusion_abridged: the abridged version of the predictions file, prefixed with the sample name (as above),
    and ending '.fusion_predictions.abridgedtsv'

## Notes
* This app is not ready for production use

## This app was made by East GLH
