import pandas as pd

######################################
# script clean up TARA metadata downloaded with `ENAmetadataKingfisherDownload.sh`
######################################

# Load the TSV file
file_path = '../data/PRJEB1787_TARA_metadata.tsv'
df = pd.read_csv(file_path, sep='\t')

# Identify columns with the same name but different cases
columns = df.columns
lowercase_to_original = {}

# Map lowercase column names to their original columns
for col in columns:
    lower_col = col.lower()
    if lower_col not in lowercase_to_original:
        lowercase_to_original[lower_col] = [col]
    else:
        lowercase_to_original[lower_col].append(col)

# Merge columns with the same name but different cases
for lower_col, col_list in lowercase_to_original.items():
    if len(col_list) > 1:
        # Combine columns into the first one
        df[col_list[0]] = df[col_list].bfill(axis=1).iloc[:, 0]
        # Drop the other columns
        df.drop(columns=col_list[1:], inplace=True)
        # Rename the remaining column to lowercase
        df.rename(columns={col_list[0]: lower_col}, inplace=True)
    else:
        # If there's only one column, just rename it to the lowercase version
        df.rename(columns={col_list[0]: lower_col}, inplace=True)

# Merge 'sample_description' and 'description' into 'sample_description'
if 'sample_description' in df.columns and 'description' in df.columns:
    df['sample_description'] = df['sample_description'].combine_first(df['description'])
    df.drop(columns=['description'], inplace=True)
elif 'description' in df.columns:
    df.rename(columns={'description': 'sample_description'}, inplace=True)

# Merge 'sample_title' and 'title', giving preference to 'title' values
if 'sample_title' in df.columns and 'title' in df.columns:
    # Replace 'sample_title' values with 'title' values where 'title' is not NA
    df['sample_title'] = df['title'].combine_first(df['sample_title'])
    df.drop(columns=['title'], inplace=True)
elif 'title' in df.columns:
    df.rename(columns={'title': 'sample_title'}, inplace=True)

# Save the cleaned dataframe back to a TSV file
df.to_csv('../data/PRJEB1787_TARA_metadata_clean.tsv', sep='\t', index=False)

print("Columns combined and file saved as '../data/PRJEB1787_TARA_metadata_clean.tsv'")

