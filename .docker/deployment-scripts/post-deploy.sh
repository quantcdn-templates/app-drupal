#!/bin/bash

## This script will run after each deployment completes.

## Cache rebuild and database updates.
drush updb -y

## Show the output of drush status.
drush status

## Configuration import example.
#drush cim -y

## Warm Drupal caches.
curl -X GET -I http://localhost
