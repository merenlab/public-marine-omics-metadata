import pandas as pd

# Load the dataset
file_path = '../data/metagenomes_filtered.txt'  # replace with your file path
df = pd.read_csv(file_path, sep='\t')

# Select only the desired columns and create a copy
columns_to_keep = ['sample', 'latitude', 'longitude', 'project', 'depth', 'temperature_degC', 'year', 'model', 'layer', 'season', 'sub_region_seavox', 'region_seavox', 'provdescr_longhurst', 'environment', 'env_biome', 'env_feature', 'env_material']
filtered_df = df[columns_to_keep].copy()

# Convert the 'year' column to float
filtered_df['year'] = filtered_df['year'].astype(float)

# Save the filtered DataFrame to a new file
filtered_df.to_csv('../data/metagenomes_filtered_anvio.txt', sep='\t', index=False)

