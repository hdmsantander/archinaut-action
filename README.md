# Archinaut Analyzer
Executes an analysis over a java project, defaults to last month of commits.

## Inputs

### init date

Starting date to analyze git log from, format is: yyyy-mm-dd.

### min cochanges

Minimum number of cochanges to report in coupling analysis. Defaults to zero.

## Example usage

_.github/workflows/main.yml_

```
on: [push]

jobs:
  gitlog_job:
    runs-on: ubuntu-latest
    name: Archinaut analysis.
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - name: Execute archinaut analysis.
        id: archinaut
        uses: hdmsantander/archinaut-action@v1.0
        with:
          init date: '2020-05-01'
          min cochanges: 0
```
