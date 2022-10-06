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
sample_name=$(echo "$junction_name" | cut -d '_' -f 1)

# create output directory to move to
mkdir -p /home/dnanexus/out/starfusion_outputs

mark-section "run starfusion"

docker run -v "$(pwd)":/data --rm \
    "${DOCKER_IMAGE_ID}" \
    STAR-Fusion \
    -J "/data/in/junction/${sample_name}_chimeric.out.junction" \
    --genome_lib_dir "/data/${lib_dir}/ctat_genome_lib_build_dir" \
    --output_dir "/data/out/starfusion_outputs"
    # --examine_coding_effect \
    # --denovo_reconstruct

mark-section "iterate over all output files and add sample names"

declare -a outnames=("star-fusion.fusion_predictions.abridged.tsv" \
    "star-fusion.fusion_predictions.tsv" \
    "pipeliner.1.cmds" \
    "_starF_checkpoints" \
    "star-fusion.preliminary" \
    "tmp_chim_read_mappings_dir")

for outfile in "${outnames[@]}"; do
    mv "/home/dnanexus/out/starfusion_outputs/${outfile}" \
    "/home/dnanexus/out/starfusion_outputs/${sample_name}_${outfile}";
done

mark-section "upload outputs"

dx-upload-all-outputs --parallel

mark-success