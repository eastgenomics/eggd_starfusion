#!/bin/bash

set -exo pipefail #if any part goes wrong, job will fail

mark-section "download inputs"
dx-download-all-inputs

# download genome resources and Docker, decompress
mkdir /home/dnanexus/genomeDir
tar xvzf /home/dnanexus/in/genome_lib/*.tar.gz -C /home/dnanexus/genomeDir #transcript data from that release of gencode
export STAR_REFERENCE=/home/dnanexus/genomeDir/*.plug-n-play/ctat_genome_lib_build_dir/ref_genome.fa.star.idx/
tar xvzf /home/dnanexus/in/sf_docker/starfusion_*.tar.gz
export DOCKER_IMAGE=/home/dnanexus/in/sf_docker/starfusion_*

# create output directory
mkdir -p out/starfusion_outputs

mark-section "run starfusion"

docker run -v `pwd`:/data --rm \
    "$DOCKER_IMAGE" \
    /usr/local/src/STAR-Fusion/STAR-Fusion \
    -J "$junctions" \
    --genome_lib_dir "$STAR_REFERENCE" \
    --output_dir "/data/out/starfusion_outputs"
    # --examine_coding_effect \
    # --denovo_reconstruct

mark-section "upload outputs"

# upload all outputs
dx-upload-all-outputs --parallel

mark-success
