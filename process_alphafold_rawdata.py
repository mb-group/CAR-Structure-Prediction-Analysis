import os
import pickle
import numpy as np
import matplotlib.pyplot as plt
import subprocess
import pandas as pd
from matplotlib.colors import LinearSegmentedColormap

# Function to get color based on pLDDT score
def get_plddt_color(plddt_score):
    if plddt_score < 50:
        return 'orange'
    elif plddt_score < 70:
        return 'yellow'
    elif plddt_score < 90:
        return 'cyan'
    else:
        return 'darkblue'

# Function to write array data to a text file
def write_array(file_path, array):
    with open(file_path, 'w') as file:
        for item in array:
            file.write(f"{item}\n")

# Function to generate PyMOL visualization scripts and execute them
def visualize_alpha_fold_model(protein_path, model_number, plddt_scores):
    # Create PyMOL script for the specific model
    pml_file_path = os.path.join(protein_path, f"result_model_{model_number}_visualization.pml")
    with open(pml_file_path, 'w') as pml_file:
        pdb_file = os.path.join(protein_path, f"relaxed_model_{model_number}_ptm.pdb")
        pml_file.write(f"load {pdb_file}, structure\n")
        pml_file.write("spectrum b, palette=rainbow, minimum=0, maximum=100\n")
        pml_file.write(f"png {os.path.join(protein_path, f'result_model_{model_number}_visualization.png')}\n")
        pml_file.write("quit\n")
    # Run PyMOL script to generate visualization
    subprocess.run(["/hpcf/authorized_apps/rhel7_apps/pymol/install/2.3.2_79/pymol", pml_file_path])

# Main directory path
main_directory = '/path/'

# List of protein directories
protein_directories = ['GRP78_1X_Pep_mutIgG4H_CD28TMz_tCd19', 
                       'CD123CAR.CD28HTM.CD28z',  
                       'GRP78.Gly4Serx3.CD123.CD28HTM.CD28z.tCD19', 
                       'GRP78.GPcPcPc.CD123.CD28HTM.CD28z.tCD19', 
                       'GRP78.mIgG4.CD123.CD28HTM.CD28z.tCD19', 
                       'GRP78.B2M.CD123.CD28HTM.CD28z.tCD19', 
                       'MGA271.CD8a.CD28z', 
                       'GRP78.G4S3.MGA271.CD8a.CD28z', 
                       'GRP78.Gly4Serx3.MGA271.CD28HTM.CD28z.tCD19']


# Lists to store pLDDT scores and PAE means for bar plots
all_plddt_scores, all_pae_means = [], []

# Iterate through protein directories
for protein_dir in protein_directories:
    protein_path = os.path.join(main_directory, protein_dir, 'scfv_no_signalpep', protein_dir)

    system_plddt_scores, system_pae_means = [], []

    # Iterate through each model (1 to 5)
    for model_number in range(1, 6):
        model_file = f"result_model_{model_number}_ptm.pkl"
        if os.path.exists(os.path.join(protein_path, model_file)):
            # Load model data from .pkl file
            with open(os.path.join(protein_path, model_file), 'rb') as file:
                model_data = pickle.load(file)

                # Extract pLDDT scores and PAE values
                plddt_scores, pae_values = model_data['plddt'], model_data['predicted_aligned_error']

                # Generate PyMOL visualization
                #visualize_alpha_fold_model(protein_path, model_number, plddt_scores)

                # Write pLDDT and PAE data to text files
                write_array(os.path.join(protein_path, f'result_model_{model_number}_ptm.pkl_plddt.txt'), plddt_scores)
                write_array(os.path.join(protein_path, f'result_model_{model_number}_ptm.pkl_pae.txt'), pae_values.flatten())

                # Store mean pLDDT and PAE values for bar plots
                system_plddt_scores.append(np.mean(plddt_scores))
                system_pae_means.append(np.mean(pae_values))

    all_plddt_scores.append(system_plddt_scores)
    all_pae_means.append(system_pae_means)

# Data to store the mean pLDDT and PAE scores for each system
data = {
    'System': protein_directories,
    'Average pLDDT': [],
    'Average PAE': [],
    'SD pLDDT': [],  
    'SD PAE': []     
}

# Iterate through the mean pLDDT and PAE scores and add them to the data
for i in range(5):
    data[f'Mean pLDDT Model {i+1}'] = [all_plddt_scores[system_index][i] for system_index in range(len(protein_directories))]
    data[f'Mean PAE Model {i+1}'] = [all_pae_means[system_index][i] for system_index in range(len(protein_directories))]

for system_index in range(len(protein_directories)):
    data['Average pLDDT'].append(sum(all_plddt_scores[system_index]) / 5)
    data['Average PAE'].append(sum(all_pae_means[system_index]) / 5)
    data['SD pLDDT'].append(np.std(all_plddt_scores[system_index]))  
    data['SD PAE'].append(np.std(all_pae_means[system_index]))       

# Create a DataFrame from the data
df_results = pd.DataFrame(data)

# Save to Excel file
output_excel_path = os.path.join(main_directory, "mean_plddt_pae_results.xlsx")
df_results.to_excel(output_excel_path, index=False)
