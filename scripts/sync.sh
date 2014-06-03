#!/bin/bash

git pull
npm install
node_modules/.bin/bower install
node_modules/.bin/brunch build -P
(cd _public && npm install)
grunt
