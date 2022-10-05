#!/bin/bash

set -exo pipefail #if any part goes wrong, job will fail

mark-section "download inputs"
dx-download-all-inputs

# load the Docker 
docker load -i /home/dnanexus/in/sf_docker/*
# Get image id of the loaded docker
DOCKER_IMAGE_ID=$(docker images --format="{{.Repository}} {{.ID}}" | grep "^trinityctat/starfusion" | cut -d' ' -f2)

# download genome resources, decompress
mkdir /home/dnanexus/genomeDir
tar xvzf /home/dnanexus/in/genome_lib/*.tar.gz -C /home/dnanexus/genomeDir
export STAR_REFERENCE=/home/dnanexus/genomeDir/GRCh38_gencode_v37_CTAT_lib_Mar012021.plug-n-play/ctat_genome_lib_build_dir/ref_genome.fa.star.idx

# create output directory
mkdir -p out/starfusion_outputs

mark-section "run starfusion"

docker run -v "$(pwd)" --rm \
    "${DOCKER_IMAGE_ID}" \
    "${STAR_FUSION_HOME}"/STAR-Fusion \
    -J "/home/dnanexus/in/junction/*Chimeric.out.junction" \
    --genome_lib_dir "$STAR_REFERENCE" \
    --output_dir "/home/dnanexus/out/starfusion_outputs"
    # --examine_coding_effect \
    # --denovo_reconstruct

mark-section "upload outputs"

# upload all outputs
dx-upload-all-outputs --parallel

mark-success
