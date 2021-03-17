#!/bin/bash

# Output each line as it is executed (-x)
set -x 

mark-section "download inputs"

# download genome resources and decompress
dx cat "$genome_lib" | tar zxf -

# download remaining inputs
dx download "$left_fq" -o R1.fastq.gz
dx download "$right_fq" -o R2.fastq.gz

# create output directory
mkdir -p out/starfusion_outputs

mark-section "setup docker"

# download starfusion docker this is August 2020 v1.9.1
docker pull trinityctat/starfusion:1.9.1

mark-section "run starfusion"

# run starfusion
docker run -v `pwd`:/data --rm trinityctat/starfusion \
    /usr/local/src/STAR-Fusion/STAR-Fusion \
    --left_fq /data/R1.fastq.gz \
    --right_fq /data/R2.fastq.gz \
    --genome_lib_dir /data/GRCh37_gencode_v19_CTAT_lib_Apr032020.plug-n-play/ctat_genome_lib_build_dir \
    -O /data/out/starfusion_outputs \
    --FusionInspector validate \
    --examine_coding_effect \
    --denovo_reconstruct

mark-section "upload outputs"

# upload all outputs
dx-upload-all-outputs --parallel

mark-success
