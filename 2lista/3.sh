#!/bin/bash
#MjQzNTE1

cats=`curl  -s 'http://thecatapi.com/api/images/get?api_key=MjQzNTE1&format=xml&results_per_page=1&type=jpg,png' | xmllint --format --xpath "(//url)" -`
cats=${cats#<*>}
cats=${cats%<*>}
curl -s $cats -o cat.jpg
img2txt cat.jpg 
joke=`curl -s http://api.icndb.com/jokes/random | jq -M -a '. | {joke: .value.joke}' | awk 'NR==2'`
joke=`echo $joke | awk '{sub("\"joke\":","")} 1'`
echo $joke