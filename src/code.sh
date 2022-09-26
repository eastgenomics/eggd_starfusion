#!/bin/bash
# eggd_starfusion 1.0.0
# Generated by dx-app-wizard.


main() {
    set -e -x -v -o pipefail #if any part goes wrong, job will fail

    mark-section "downloading inputs"
    dx-download-all-inputs

    mark-section "install sentieon, run license setup script"
    tar xvzf /home/dnanexus/in/sentieon_tar/sentieon-genomics-*.tar.gz -C /usr/local

    source /home/dnanexus/license_setup.sh
    export SENTIEON_INSTALL_DIR=/usr/local/sentieon-genomics-*
    SENTIEON_BIN_DIR="$SENTIEON_INSTALL_DIR/bin"
    export PATH="$SENTIEON_BIN_DIR:$PATH"

    mark-section "set up Star-fusion parameters and paths"
    NUMBER_THREADS=4
    # Reference transcripts
    export STAR_REFERENCE=/home/dnanexus/genomeDir/*.plug-n-play/ctat_genome_lib_build_dir/ref_genome.fa.star.idx/

    mark-section "run STAR-fusion"
    sentieon STAR-Fusion \
    -J "$junctions" \
    --genome_lib_dir "$STAR_REFERENCE" \
    --output_dir "$outdir"
    

    mark-section "Preparing the outputs for upload"
	mv ~/"$outdir" ~/out/"$outdir"
    mark-success
}
