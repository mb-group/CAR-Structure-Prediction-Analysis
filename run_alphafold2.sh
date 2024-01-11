#!/bin/bash
#BSUB -J mga271
#BSUB -P af_run
#BSUB -q gpu
#BSUB -n 8 
#BSUB -R "span[hosts=1]"     #request all cores on the same node 
#BSUB -R "rusage[mem=32GB]"  # adjust this according to the memory requirement per node you need
#BSUB -gpu "num=1/host:mode=exclusive_process"
#BSUB -o outfile.out
#BSUB -e outfile.err
##BSUB -cwd /pathtofile/

fasta=mga271.fasta
preset=monomer_ptm

export WORKDIR=$PWD
export DOWNLOAD_DIR=/research_jude/rgs01_jude/reference/public/alphafold_data

if [ "$preset" == "monomer" ];
then
    echo "Running in monomer mode"
    singularity run --env TF_FORCE_UNIFIED_MEMORY=1,XLA_PYTHON_CLIENT_MEM_FRACTION=4.0,OPENMM_CPU_THREADS=8 -B ${DOWNLOAD_DIR}:/data -B .:/etc --pwd ${WORKDIR} \
        --nv docker://svlpdocker01.stjude.org/alphafold:latest \
        --max_template_date=$(date +"%Y-%m-%d") \
        --db_preset=full_dbs \
        --fasta_paths=${WORKDIR}/$fasta \
        --output_dir=${WORKDIR}

elif [ "$preset" == "monomer_ptm" ];
then
    echo "Running in monomer_ptm mode"
    singularity run --env TF_FORCE_UNIFIED_MEMORY=1,XLA_PYTHON_CLIENT_MEM_FRACTION=4.0,OPENMM_CPU_THREADS=8 -B ${DOWNLOAD_DIR}:/data -B .:/etc --pwd ${WORKDIR} \
        --nv  docker://svlpdocker01.stjude.org/alphafold:latest\
        --max_template_date=$(date +"%Y-%m-%d") \
        --model_preset=monomer_ptm \
        --pdb_seqres_database_path= \
        --db_preset=full_dbs \
        --fasta_paths=${WORKDIR}/$fasta \
        --output_dir=${WORKDIR}

elif [ "$preset" == "multimer" ];
then
    echo "Running in multimer mode"
    singularity run --env TF_FORCE_UNIFIED_MEMORY=1,XLA_PYTHON_CLIENT_MEM_FRACTION=4.0,OPENMM_CPU_THREADS=8 -B ${DOWNLOAD_DIR}:/data -B .:/etc --pwd ${WORKDIR} \
        --nv docker://svlpdocker01.stjude.org/alphafold:latest \
        --is_prokaryote_list=false \
        --model_preset=multimer \
        --max_template_date=$(date +"%Y-%m-%d") \
        --db_preset=full_dbs \
        --fasta_paths=${WORKDIR}/$fasta \
        --output_dir=${WORKDIR}/
else
    echo "Running mode must be monomer or multimer"
    exit 0
fi

WORKDIR=$PWD
