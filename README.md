# Some COVID-related Scripts

Scripts and shiny apps I've used to play around with the [New York Times' COVID-19 data](https://github.com/nytimes/covid-19-data)

## Get the data

```bash
cd data
git clone https://github.com/nytimes/covid-19-data.git
```

### Update daily

```bash
cd data/covid-19-data/
git pull
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

## Anomalies

The script `anomaly_detection.r` and the accompanying shiny app `anomaly_table` produce a list of counties and dates where each row represents a county whose case and/or death count on one day was less than the previous date. Results from me having run this are available in `weird_counties.csv` (note: this might not be up to date with latest NYT data)

## Indiana Data

**The state no longer provides this file (boo). JSON version should still work.**

The `Indiana_Cumulative_Counts` directory contains an RShiny app that parses the `COVID-19 CASE DATA` csv file available at [Indiana's Data Hub](https://hub.mph.in.gov/dataset?q=COVID) and returns the cumulative case count in each county by day. I've included a dataset in this directory, but likely you'll want to download something more recent from the Data Hub.

The `indiana_json` directory has an Rshiny app and some additional code for pulling data from the state's JSON feed.