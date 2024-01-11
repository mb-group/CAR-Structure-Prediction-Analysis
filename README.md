# CAR-Structure-Prediction-Analysis
A repository for the cell reports medicine manuscript titled 'Structural changes to linker length and complexity impact functional outcomes in bispecific CAR T cells'

CAR structures were initially predicted with AlphaFold2. AlphaFold2 software was installed and implemented in the local HPC cluster and the bash script titled 'run_alphafold2.sh' was used to conduct AlphaFold2 structural predictions on the cluster. Further, a python script titled 'process_alphafold_rawdata.py' was used to extract respective PAE and PLDDT data for the AlphaFold2 predicted CAR structure models. Finally, a bash script titled 'plot_pae_plddt.sh' was used to plot the respective PAE and PLDDT data for the CAR structural models. 

All fasta files that are required to make structural predictions, as well as the extracted PAE and PLDDT data files that are required to generate PAE and PLDDT image files are also provided. 
