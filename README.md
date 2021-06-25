# Archinaut Analyzer
Executes complexity and dependency analysis over a *java* project, generates metrics and generates an XML JUnit report that allows for threshold verification on those metrics.

## Basic inputs

These inputs are *needed* to run the action.

### configuration file

Path to the configuration file that holds the Archinaut settings in a YAML format. The configuration file is divided by sections, each section being a source of metrics (metric report) that can be integrated by Archinaut. The current **formats** recognized by Archinaut are: 

* [CSV](https://en.wikipedia.org/wiki/Comma-separated_values)
* [DEPENDS](https://github.com/multilang-depends/depends)

The **file** declared in each section must be an existing file, reachable by Archinaut at runtime.

The **renaming** section is used to standarize names of the objects inside the metric reports, prefixes and suffixes are removed and then substitutions of characters are performed in the order defined.

The **metrics** section is used to declare the numeric (integer) metrics that are to be loaded from the metric reports. The one marked with the boolean *filename* serves as the identifier for the filename in the report, there can only be one *filename* flag specified. The metrics can be renamed if a **rename** is specified.

The metric report provided by [depends](https://github.com/multilang-depends/depends) is non-optional and its generated with the following [depends](https://github.com/multilang-depends/depends) options: `java -jar $DEPENDS_JAR -s -p dot -d $HOME java ./src depends`

An example of the *archinaut.yml* file can be seen here:

_archinaut.yml_
```YAML
---
file: 'scc.csv'
format: 'CSV'
renaming:
  pathSeparator: '/'
  prefix: 'src/main/java/'
  suffix: ''
  substitutions:
    - order: 1
      substitute: '.'
      with: '_'
    - order: 2
      substitute: '/'
      with: '_'
metrics:
  - name: 'Location'
    filename: true
  - name: 'Lines'
    rename: 'SCC_LOC'
  - name: 'Code'
    rename: 'SCC_CLOC'
  - name: 'Complexity'
    rename: 'SCC_COMPLEXITY'
---
file: 'frecuencies.csv'
format: 'CSV'
renaming:
  pathSeparator: '/'
  prefix: 'src/main/java/'
  suffix: ''
  substitutions:
    - order: 1
      substitute: '.'
      with: '_'
    - order: 2
      substitute: '/'
      with: '_'
metrics:
  - name: 'entity'
    filename: true
  - name: 'n-revs'
    rename: 'ARCH_REVISIONS'
  - name: 'bugs'
    rename: 'BUG_COMMITS'
  - name: 'added'
    rename: 'LINES_ADDED'
  - name: 'removed'
    rename: 'LINES_REMOVED'
---
file: 'coupling.csv'
format: 'CSV'
renaming:
  pathSeparator: '/'
  prefix: 'src/main/java/'
  suffix: ''
  substitutions:
    - order: 1
      substitute: '.'
      with: '_'
    - order: 2
      substitute: '/'
      with: '_'
metrics:
  - name: 'entity'
    filename: true
  - name: 'cochanges'
    rename: 'COCHANGES'
---
file: 'depends.json'
format: 'DEPENDS'
renaming:
  pathSeparator: '.'
  prefix: 'main.java.'
  suffix: ''
  substitutions:
    - order: 1
      substitute: '.'
      with: '_'
metrics:
  - name: 'Call'
  - name: 'Import'
  - name: 'Return'
  - name: 'Use'
  - name: 'Parameter'
  - name: 'Contain'
  - name: 'Implement'
  - name: 'Create'
  - name: 'Extend'

```

### init date

Starting date to analyze the repositorys git log, format is: yyyy-mm-dd. Defaults to last month.

### min cochanges

Minimum number of cochanges to report in coupling analysis. Defaults to zero.


## Threshold inputs

These inputs are *optional* and serve to generate a JUnit format XML report with the threshold violations.

Given any **metrics** declared in the configuration file, an input can be declared in the action specification, that will work as a threshold to generate a JUnit style XML report with the violations of said thresholds. For example, in the **archinaut.yml** file we specified the metrics *SCC_LOC*, *SCC_CLOC* and *SCC_COMPLEXITY*, so in the **with** section of the action declaration in the workflow we can declare the following inputs:

* scc loc: 150
* scc cloc: 100
* scc complexity: 15

These inputs will be parsed and used at runtime to generate a JUnit style XML report with the violations detected. 

## Example usage in a workflow

_.github/workflows/main.yml_

```YAML
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
          configuration file: archinaut.yml
          init date: '2020-01-01'
          min cochanges: 0
          scc loc: 150
          scc cloc: 100
          scc complexity: 15
      
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
