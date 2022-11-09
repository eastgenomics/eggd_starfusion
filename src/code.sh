#!/bin/bash

set -exo pipefail #if any part goes wrong, job will fail

# download all inputs, untar the plug-n-play resources, and get the name of the untarred directory
mark-section "download inputs"
dx-download-all-inputs
mkdir /home/dnanexus/ctat_unpacked
tar xf /home/dnanexus/in/genome_lib/*.tar.gz -C /home/dnanexus/ctat_unpacked
lib_dir=$(find /home/dnanexus/ctat_unpacked -type d -name "*" -mindepth 1 -maxdepth 1 | rev | cut -d'/' -f-1 | rev)

# make output dirs for later
mkdir -p /home/dnanexus/out/starfusion_predictions
mkdir /home/dnanexus/out/starfusion_abridged

# load the Docker and get its image ID
docker load -i /home/dnanexus/in/sf_docker/*.tar.gz
DOCKER_IMAGE_ID=$(docker images --format="{{.Repository}} {{.ID}}" | grep "^trinityctat/starfusion" | cut -d' ' -f2)

# get the sample name from the chimeric file
sample_name=$(echo "$junction_name" | cut -d '.' -f 1)

mark-section "run starfusion to a temporary 'out' directory"
mkdir /home/dnanexus/temp_out

docker run -v "$(pwd)":/data --rm \
    "${DOCKER_IMAGE_ID}" \
    STAR-Fusion \
    -J "/data/in/junction/${sample_name}.chimeric.junction.out" \
    --genome_lib_dir "/data/ctat_unpacked/${lib_dir}/ctat_genome_lib_build_dir" \
    --output_dir "/data/temp_out"

mark-section "move relevant output files, and add sample names"
# rename and move summary files to output directories
find /home/dnanexus/temp_out -type f -name "*fusion_predictions.abridged.tsv" -printf "%f\n" | \
xargs -I{} mv /home/dnanexus/temp_out/{} /home/dnanexus/out/starfusion_predictions/"${sample_name}"_{}
find /home/dnanexus/temp_out -type f -name "*fusion_predictions.tsv" -printf "%f\n" | \
xargs -I{} mv /home/dnanexus/temp_out/{} /home/dnanexus/out/starfusion_abridged/"${sample_name}"_{}

mark-section "upload outputs"

dx-upload-all-outputs --parallel

mark-success