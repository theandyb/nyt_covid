# Some COVID-related Scripts

Scripts and shiny apps I've used to play around with the [New York Times' COVID-19 data](https://github.com/nytimes/covid-19-data)

## Get the data

Note: this might not be the most efficient way of doing this, but the scripts in this repository will assume that the `us-counties.csv` and `us-states.csv` files are in the top-level of the `data` directory.

```bash
cd data
git clone https://github.com/nytimes/covid-19-data.git
mv covid-19-data/* ./
rm -rf covid-19-data
```

## Cumulative cases by county for each day

The file `cumulative_counts_by_county.R` generates an excel document with the cumulative cases by counties across the dates in which there is data.

### Accompanying Shiny App

The `cumulative_by_state` directory contains a simple shiny app to navigate the county-level cumulative counts by state and date. Either run from rStudio, or from an open R session in this directory run

```r
library(rshiny)
runApp('cumulative_by_state')
```

## Growth over time

The directory `growth_over_time` has a simple R shiny app to look at how case numbers have grown over time in each county.

```r
library(shiny)
runApp('growth_over_time')
```
