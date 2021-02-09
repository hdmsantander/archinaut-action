# Archinaut Analyzer
Executes complexity and dependency analysis over a *java* project, generates metrics and generates an XML JUnit report that allows for threshold verification on those metrics.

## Basic inputs

### init date

Starting date to analyze the repositorys git log, format is: yyyy-mm-dd. Defaults to last month.

### min cochanges

Minimum number of cochanges to report in coupling analysis. Defaults to zero.

## Threshold inputs
The following inputs can be set with a numerical value to generate a JUnit XML report that evaluates the supplied thresholds.

### scc loc
Maximum total lines of code allowed for a single file

### scc cloc
Maximum logical lines of code allowed for a single file

### scc complexity
Maximum complexity allowed for a single file

### arch revisions
Maximum number of commits for a single file

### arch dependent partners
Maximum number of files that can depend on a single file

### arch depends on partners
Maximum number of files that a file is allowed to depend from

### arch total dependencies
Maximum sum of the previous two metrics

### arch cochange partners
Maximum number of other simultaneous files to be modified in the same commit to a file

### arch churn
Maximum accumulated lines of code changed during all commits to a file

## Example usage

_.github/workflows/main.yml_

```
on: [push]
jobs:
  archinaut-analysis:
    runs-on: ubuntu-latest
    name: A job to perform archinaut analysis of source code
    steps:

      # Check out the repository
      - name: Checkout
        uses: actions/checkout@v2.3.4
      
      # Use the Archinaut action
      - name: Archinaut analysis
        id: archinaut
        uses: hdmsantander/archinaut-action@main
        with:
          init date: '2020-01-01'
          min cochanges: 0
          scc cloc: 450
          scc complexity: 70
          scc loc: 410
          arch revisions: 30
          arch dependent partners: 50
          arch depends on partners: 70
          arch total dependencies: 70
          arch cochange partners: 20
          arch churn: 500
      
      # Use the generated "archinaut.xml" file to report the results in merge requests if there's
      # one associated with this commit
      - name: Generate report using Archinaut XML output
        uses: EnricoMi/publish-unit-test-result-action@v1.7
        if: always()
        with:
         check_name: 'Archinaut analysis results'
         report_individual_runs: true
         github_token: ${{ secrets.GITHUB_TOKEN }}
         files: archinaut.xml
```
