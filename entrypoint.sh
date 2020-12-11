#!/bin/bash

HOME=/home/archinaut

git --version

# First SCC
echo "Executing scc analysis"
scc --by-file --ci -i java -o $HOME/scc.csv -f csv

# Then depends
echo "Executing depends analysis"
java -jar $HOME/depends.jar -s -p dot -d $HOME java src depends

echo "Executing git log analyzer"
# Then we use gitloganalyzer
if [ -n "$INPUT_INIT_DATE" ]; then
    echo "Using start date $INPUT_INIT_DATE"
    git log --pretty=format:'[%h] %an %ad %s' --date=short --numstat --after=$INPUT_INIT_DATE > $HOME/git.log
else
    MIN_DATE=$(date +'%Y-%m-%d' -d 'last month')
    echo "Looking for commits since $MIN_DATE"
    git log --pretty=format:'[%h] %an %ad %s' --date=short --numstat --after=$MIN_DATE > $HOME/git.log
fi

java -jar $HOME/gitloganalyzer.jar -f $HOME/git.log > frecuencies.csv
java -jar $HOME/gitloganalyzer.jar -f $HOME/git.log -coupling $INPUT_MIN_COCHANGES > coupling.csv

# Finally we use archinaut
ls -la $HOME
cat $HOME/scc.csv
cat $HOME/depends
cat $HOME/git.log
cat $HOME/frecuencies.csv
cat $HOME/coupling.csv
