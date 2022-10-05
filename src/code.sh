#!/bin/bash

set -exo pipefail #if any part goes wrong, job will fail

mark-section "download inputs"
dx-download-all-inputs
tar xf /home/dnanexus/in/genome_lib/*.tar.gz -C /home/dnanexus/


# find the plug-n-play resources
lib_dir=$(find . -type d -name "GR*plug-n-play")

# load the Docker 
docker load -i /home/dnanexus/in/sf_docker/*.tar.gz
# Get image id of the loaded docker
DOCKER_IMAGE_ID=$(docker images --format="{{.Repository}} {{.ID}}" | grep "^trinityctat/starfusion" | cut -d' ' -f2)

# create output directory
mkdir -p out/starfusion_outputs

mark-section "run starfusion"

docker run -v "$(pwd)":/data --rm \
    "${DOCKER_IMAGE_ID}" \
    STAR-Fusion \
    -J "/data/in/junction/*Chimeric.out.junction" \
    --genome_lib_dir "/data/${lib_dir}/ctat_genome_lib_build_dir" \
    --output_dir "/data/out/starfusion_outputs"
    # --examine_coding_effect \
    # --denovo_reconstruct

mark-section "upload outputs"

# upload all outputs
dx-upload-all-outputs --parallel

mark-success