# Some COVID-related Scripts

## Get the data

Note: this might not be the most efficient way of doing this, but the scripts in this repository will assume that the `us-counties.csv` and `us-states.csv` files are in the top-level of the `data` directory.

```bash
cd data
git clone https://github.com/nytimes/covid-19-data.git
mv covid-19-data/* ./
rm -rf covid-19-data
```

## Cumulative cases by county for each day

The file `cumulative_counts_by_county.R` will generate a table for each day with the cumulative counts for cases and deaths at the county level. 
