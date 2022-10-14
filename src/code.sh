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
mkdir -p /home/dnanexus/out/"${sample_name}_STAR-Fusion"

mark-section "run starfusion"

docker run -v "$(pwd)":/data --rm \
    "${DOCKER_IMAGE_ID}" \
    STAR-Fusion \
    -J "/data/in/junction/${sample_name}.chimeric.out.junction" \
    --genome_lib_dir "/data/${lib_dir}/ctat_genome_lib_build_dir" \
    --output_dir "/data/out/starfusion_outputs"

mark-section "iterate over all output files and add sample names"

outnames=$(find /home/dnanexus/out/starfusion_outputs -name "*")
declare -a outarray
while read -r line; do
    # cut off the starting ./
    line=$(sed 's/^.\///' <<< "${line}")
    outarray+=("${line}")
done < "${outnames}"


for outfile in "${outarray[@]}"; do
    mv "/home/dnanexus/out/starfusion_outputs/${outfile}" \
    "/home/dnanexus/out/${sample_name}_STAR-Fusion/${sample_name}.${outfile}";
done

mark-section "upload outputs"

dx-upload-all-outputs --parallel

mark-success