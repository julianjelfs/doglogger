# Everything we need / want to track about the dog

* poos 
* house training transgressions
* weight
* vaccinations 
* flea / worm stuff

## Data structure

All dates and times are going to be stored as posix. We'll sort out later 
what to do about the charts and DST etc.

```
poos: posix[],
woopsies: posix[],
weights: { posix, weight }[],
schedule: ???
```