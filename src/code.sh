#!/bin/bash

# Output each line as it is executed (-x)
set -x 

mark-section "download inputs"

# download genome resources and decompress
dx cat "$genome_lib" | tar zxf -

# download remaining inputs
dx download "$junction" -o Chimeric.out.junction

# create output directory
mkdir -p out/starfusion_outputs
lib_dir=$(find . -type d -name "GR*plug-n-play")

mark-section "run starfusion"

# run starfusion
docker run -v `pwd`:/data --rm trinityctat/starfusion \
    /usr/local/src/STAR-Fusion/STAR-Fusion \
    --left_fq /data/R1.fastq.gz \
    --right_fq /data/R2.fastq.gz \
    --genome_lib_dir /data/"${lib_dir}/ctat_genome_lib_build_dir" \
    -O /data/out/starfusion_outputs 
    # --examine_coding_effect \
    # --denovo_reconstruct

mark-section "upload outputs"

# upload all outputs
dx-upload-all-outputs --parallel

mark-success
