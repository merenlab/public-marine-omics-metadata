
########################
# script to download table 3: "Detailed sampling location and accession information for all metagenomic datasets" from
# Biller, S., Berube, P., Dooley, K. et al. Marine microbial metagenomes sampled across space and time. Sci Data 5, 180176 (2018). https://doi.org/10.1038/sdata.2018.176
########################

import requests
from bs4 import BeautifulSoup
import csv

url = 'https://www.nature.com/articles/sdata2018176/tables/4'
response = requests.get(url)
soup = BeautifulSoup(response.text, 'html.parser')

table = soup.find('table')  # Adjust this if there are multiple tables

# Extracting the table headers
headers = [header.text for header in table.find_all('th')]

# Extracting the rows
rows = []
for row in table.find_all('tr'):
    columns = row.find_all('td')
    rows.append([column.text.strip() for column in columns])

# Writing to CSV
with open('../data/metadataDataSciBGT.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(headers)
    writer.writerows(rows)

print("Data has been written to output.csv")

