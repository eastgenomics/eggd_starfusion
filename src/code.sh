#!/bin/bash

set -exo pipefail #if any part goes wrong, job will fail

# download all inputs, untar the plug-n-play resources, and get the name of the untarred directory
mark-section "download inputs"
dx-download-all-inputs
mkdir /home/dnanexus/ctat_unpacked
tar xf /home/dnanexus/in/genome_lib/*.tar.gz -C /home/dnanexus/ctat_unpacked
lib_dir=$(find /home/dnanexus/ctat_unpacked -type d -name "*" -mindepth 1 -maxdepth 1 | rev | cut -d'/' -f-1 | rev)

# load the Docker and get its image ID
docker load -i /home/dnanexus/in/sf_docker/*.tar.gz
DOCKER_IMAGE_ID=$(docker images --format="{{.Repository}} {{.ID}}" | grep "^trinityctat/starfusion" | cut -d' ' -f2)

# get the sample name from the chimeric file
sample_name=$(echo "$junction_name" | cut -d '.' -f 1)

mark-section "run starfusion"

docker run -v "$(pwd)":/data --rm \
    "${DOCKER_IMAGE_ID}" \
    STAR-Fusion \
    -J "/data/in/junction/${sample_name}.chimeric.junction.out" \
    --genome_lib_dir "/data/ctat_unpacked/${lib_dir}/ctat_genome_lib_build_dir" \
    --output_dir "/data/out"

mark-section "move all output files to a named directory, and add sample names"
# create output parent directory to move to
final_dir="/home/dnanexus/out/${sample_name}_STAR-Fusion"
mkdir -p "${final_dir}"

# rename and move summary files
find /home/dnanexus/out -type f -name "*pipeliner.*.cmds" -printf "%f\n" | \
xargs -I{} mv /home/dnanexus/out/{} "${final_dir}"/"${sample_name}"_{}
find /home/dnanexus/out -type f -name "*fusion_predictions.abridged.tsv" -printf "%f\n" | \
xargs -I{} mv /home/dnanexus/out/{} "${final_dir}"/"${sample_name}"_{}
find /home/dnanexus/out -type f -name "*fusion_predictions.tsv" -printf "%f\n" | \
xargs -I{} mv /home/dnanexus/out/{} "${final_dir}"/"${sample_name}"_{}

# move temp directories, excluding the parent one we just made
find /home/dnanexus/out -type d -name "*" -not -path "${final_dir}" -printf "%f\n" | \
xargs -I{} mv /home/dnanexus/out/{} "${final_dir}"/

mark-section "upload outputs"

dx-upload-all-outputs --parallel

mark-success