#!/bin/bash

cd $(dirname $0)

bundle exec ruby scraper.rb $(jq -r .source meta.json) |
  qsv select id,name,positionID,position,startDate,endDate |
  qsv rename item,itemLabel,position,positionLabel,startDate,endDate > scraped.csv

wd sparql -f csv wikidata.js | sed -e 's/T00:00:00Z//g' -e 's#http://www.wikidata.org/entity/##g' | qsv dedup -s psid > wikidata.csv

bundle exec ruby diff.rb | qsv sort -s positionlabel,startdate,itemlabel | tee diff.csv

cd ~-
