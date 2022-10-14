#!/bin/bash

set -exo pipefail #if any part goes wrong, job will fail

# download all inputs, untar the plug-n-play resources, and get its path
mark-section "download inputs"
dx-download-all-inputs
tar xf /home/dnanexus/in/genome_lib/*.tar.gz -C /home/dnanexus/
lib_dir=$(find . -type d -name "GR*plug-n-play")

# load the Docker and get its image ID
docker load -i /home/dnanexus/in/sf_docker/*.tar.gz
DOCKER_IMAGE_ID=$(docker images --format="{{.Repository}} {{.ID}}" | grep "^trinityctat/starfusion" | cut -d' ' -f2)

# get the sample name from the chimeric file
sample_name=$(echo "$junction_name" | cut -d '.' -f 1)

# create output directory to move to
final_dir="/home/dnanexus/out/${sample_name}_STAR-Fusion"
mkdir -p "${final_dir}"

mark-section "run starfusion"

docker run -v "$(pwd)":/data --rm \
    "${DOCKER_IMAGE_ID}" \
    STAR-Fusion \
    -J "/data/in/junction/${sample_name}.chimeric.out.junction" \
    --genome_lib_dir "/data/${lib_dir}/ctat_genome_lib_build_dir" \
    --output_dir "/data/out"

mark-section "move all output files to a sample-named directory, and rename them all to have the sample name too"

for f in ${final_dir} ; do mv -- "$f" "${sample_name}.$f" ; done

mark-section "upload outputs"

dx-upload-all-outputs --parallel

mark-success