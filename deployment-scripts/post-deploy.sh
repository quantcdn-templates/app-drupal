#!/bin/bash


## This script will run after each deployment completes.
drush status

drush cr
drush updb -y

## Configuration import example.
drush cex -y
#drush cim -y