#!/bin/bash

set -exo pipefail #if any part goes wrong, job will fail

# download all inputs, untar the plug-n-play resources, and get its path
mark-section "download inputs"
dx-download-all-inputs
gzip -d /home/dnanexus/in/genome_lib/*
lib_file=$(find /home/dnanexus/in/genome_lib -type -f -name "*" -printf "%f")

# load the Docker and get its image ID
docker load -i /home/dnanexus/in/sf_docker/*.tar.gz
DOCKER_IMAGE_ID=$(docker images --format="{{.Repository}} {{.ID}}" | grep "^trinityctat/starfusion" | cut -d' ' -f2)

# get the sample name from the chimeric file
sample_name=$(echo "$junction_name" | cut -d '.' -f 1)

mark-section "run starfusion"

docker run -v "$(pwd)":/data --rm \
    "${DOCKER_IMAGE_ID}" \
    STAR-Fusion \
    -J "/data/in/junction/${sample_name}.chimeric.out.junction" \
    --genome_lib_dir "/data/in/genome_lib/${lib_file}" \
    --output_dir "/data/out"

mark-section "move all output files to a named directory, and add sample names"
# create output directory to move to
final_dir="/home/dnanexus/out/${sample_name}_STAR-Fusion"
mkdir -p "${final_dir}"
# rename and move files
find /home/dnanexus/out -type f -name "*" -printf "%f\n" | \
xargs -I{} mv /home/dnanexus/out/{} "${final_dir}"/"${sample_name}"_{}

mark-section "upload outputs"

dx-upload-all-outputs --parallel

mark-success