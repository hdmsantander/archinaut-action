#!/bin/bash
HOME=/home/archinaut

SCC_EXECUTABLE=$HOME/scc
DEPENDS_JAR=$HOME/depends.jar
GITLOG_JAR=$HOME/gitloganalyzer.jar
ARCHINAUT_JAR=$HOME/archinaut.jar

# Check for executables
if [[ ! -r $DEPENDS_JAR || ! -r $GITLOG_JAR || ! -x $SCC_EXECUTABLE || ! -r $ARCHINAUT_JAR ]]; then
    echo "Missing executable(s), stopping..."
    exit 1
fi

# First use SCC
echo "Executing scc analysis"
$SCC_EXECUTABLE --by-file --ci -i java -o scc.csv -f csv

# Check that the SCC output is usable
if [[ ! -r scc.csv ]]; then
    echo "Couldn't generate SCC output"
    exit 1
fi

# Then run depends
echo "Executing depends analysis"
java -jar $DEPENDS_JAR -s -p dot -d ./ java ./src depends

# Check that the depends output is usable
if [[ ! -r depends.json ]]; then
    echo "Couldn't generate depends output"
    exit 1
fi

# Generate the git log
echo "Executing git log analyzer"
git --version

# Check if the input init date input is set, else use last month's commits
if [ -n "$INPUT_INIT_DATE" ]; then
    echo "Using start date $INPUT_INIT_DATE"
    git log --pretty=format:'[%h] %an %ad %s' --date=short --numstat --after=$INPUT_INIT_DATE > git.log
else
    MIN_DATE=$(date +'%Y-%m-%d' -d 'last month')
    echo "Looking for commits since $MIN_DATE"
    git log --pretty=format:'[%h] %an %ad %s' --date=short --numstat --after=$MIN_DATE > git.log
fi

# Check if the git log was generated
if [[ ! -r  git.log ]]; then
    echo "Git log is empty, stopping..."
    exit 1
else
    
    # Run the GitLog analyzer, min cochanges defaults to 0
    java -jar $GITLOG_JAR -f git.log > frequencies.csv
    java -jar $GITLOG_JAR -f git.log -coupling $INPUT_MIN_COCHANGES > coupling.csv
    
    # Check if the git log analyzer output is usable and it was generated
    if [[ ! -r frequencies.csv || ! -r coupling.csv ]]; then
        echo "Couldn't generate git log analyzer output"
        exit 1
    fi
    
fi

# Check that the archinaut configuration file is present
if [[ ! -r $INPUT_CONFIGURATION_FILE ]]; then
    echo "Couldn't reach archinaut configuration file"
    exit 1
fi

# Execute Archinaut analysis, all files exist if script is still running at this point, this generates archinaut.csv
java -jar $ARCHINAUT_JAR --configuration $INPUT_CONFIGURATION_FILE

# Check that archinaut output was generated
if [[ ! -r archinaut.csv || ! -r archinaut.xml ]]; then
    echo "Archinaut output couldn't be generated..."
    exit 1
fi

# For now we just cat them both to STDOUT
cat archinaut.csv
cat archinaut.xml
