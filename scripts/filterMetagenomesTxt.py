import pandas as pd

# Step 1: Read the unique samples file
with open('../../../digital_sup/metadataForAnvio/unique_samples.txt', 'r') as f:
    unique_samples = f.read().splitlines()

# Step 2: Read the metagenomes file
metagenomes_df = pd.read_csv('../data/metagenomes.txt', sep='\t')

# Step 3: Create a dictionary to map `biosample` to the full sample name
sample_mapping = {sample.split('_')[1]: sample for sample in unique_samples}

# Step 4: Filter the metagenomes data where `biosample` matches the key in `sample_mapping`
filtered_df = metagenomes_df[metagenomes_df['biosample'].isin(sample_mapping.keys())].copy()

# Step 5: Add a new column `sample` with the full sample name
filtered_df['sample'] = filtered_df['biosample'].map(sample_mapping)

# Step 6: Group by the 'sample' column and aggregate each column by concatenating unique values
aggregated_df = filtered_df.groupby('sample').agg(lambda x: ','.join(sorted(set(x.dropna().astype(str)))))

# Step 7: Reset the index to make 'sample' a column again
aggregated_df.reset_index(inplace=True)

# Step 8: Reorder columns to make `sample` the first column
cols = ['sample'] + [col for col in aggregated_df.columns if col != 'sample']
aggregated_df = aggregated_df[cols]

# Step 9: Write the resulting DataFrame to a new file
aggregated_df.to_csv('../data/metagenomes_filtered.txt', sep='\t', index=False)

