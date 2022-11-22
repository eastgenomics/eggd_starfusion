# eggd_starfusion v1.0.0

## What does this app do?
Runs STAR-Fusion, a tool which identifies candidate fusion transcripts from RNA alignments, from its official Docker image. This app is specifically set up to process the 'Chimeric.out.junction' files produced by the earlier STAR-Aligner alignment step. It produces files of candidate fusion regions.

## What inputs are required for this app to run?
* The DNA Nexus file ID of a junction file, produced by STAR-Aligner
    * The file should be named in the format 'sample_name.chimeric.out.junction'
    * The file name is split on '.' and the first field used to name the output files
* The DNA Nexus file ID of a STAR genome resource, which should be a compressed '.tar.gz' file - from https://data.broadinstitute.org/Trinity/CTAT_RESOURCE_LIB/
* The DNA Nexus file ID of a saved STAR-Fusion Docker image, which should be a compressed '.tar.gz'
* Additional parameters can be passed using 'opt_parameters', which should be a space-delimited string. If additional parameters aren't passed, the defaults will run. 
    * Options available are detailed at the bottom of the page under 'Appendix 1'.

## How does this app work?
* Downloads and unzips/untars the STAR genome resource
* Downloads the sample junction file
* Loads and runs the STAR-Fusion Docker image using default settings
    * Production versions of this app will need to point to a controlled Docker image in 'references' on DNAnexus to ensure that the same version is run each time
* Prefixes output file names with the sample name
* Uploads the output files to DNA Nexus

## What does this app output?
* The app generates:
    * starfusion_predictions: the predictions file prefixed with the sample name (extracted from the StarAligner junctions file), and ending '.fusion_predictions.tsv'
    * starfusion_abridged: the abridged version of the predictions file, prefixed with the sample name (as above),
    and ending '.fusion_predictions.abridged.tsv'

## Appendix: Additional options 
# Options which may be useful
Further options available to change in STAR-Fusion, and obtained by running 'STAR-Fusion -h' inside an interactive Docker, are as below. For more information about the purpose of each parameter, see the 'help' messages for each parameter at https://github.com/STAR-Fusion/STAR-Fusion/blob/master/STAR-Fusion:

STAR program configurations:
* --STAR_max_mate_dist INT
* --STAR_SJDBoverhangMin INT
* --STAR_SortedByCoordinate
* --STAR_onepass

Stitching overlapping reads settings:
* --STAR_peOverlapNbasesMin INT    
* --STAR_peOverlapMMp INT

STAR chim multi-map opts:
* --STAR_chimMultimapScoreRange INT
* --STAR_chimMultimapNmax INT
* --STAR_chimNonchimScoreDropMin INT
* --STAR_outSAMattrRGline STR

Chimeric read filtering parameters:
* --min_pct_MM_nonspecific|M INT

Fusion transcript filtering:
* --min_junction_reads INT
* --min_sum_frags INT
* --require_LDAS 0|1
* --max_promiscuity INT
* --min_pct_dom_promiscuity INT
* --aggregate_novel_junction_dist INT
* --min_novel_junction_support INT
* --min_spanning_frags_only INT
* --min_alt_pct_junction FLOAT
* --min_FFPM FLOAT
* --no_remove_dups
* --skip_EM
* --skip_FFPM

Turn off specific fusion filters:
* --no_annotation_filter
* --no_RT_artifact_filter
* --no_single_fusion_per_breakpoint

Downstream analysis of fusion candidates:
* --extract_fusion_reads

Miscellaneous options:
* --verbose_level INT
* --max_sensitivity
* --full_Monty

# Options which are irrelevant or app-controlled
The below options only control where files are output and how resources are allocated, and are either not used, or are managed by the app: 
* --output_dir
* --CPU
* --STAR_PATH
* --STAR_limitBAMsortRAM
* --tmpdir
* --STAR_use_shared_memory
* --STAR_LoadAndExit
* --STAR_Remove
* --outTmpDir STR

The below options are unlikely to be needed, because the workflow relies on a separate, StarAligner step being run to generate an initial predictions file, and a later FusionInspector step which examines coding effect after validating:
* --left_fq
* --right_fq
* --run_STAR_only
* --examine_coding_effect
* --no_filter
* --FusionInspector STR (inspect/validate)
* --denovo_reconstruct
* --misc_FI_opts STR
* --version
* --samples_file STR (intended for single-cell)

## This app was made by East GLH
