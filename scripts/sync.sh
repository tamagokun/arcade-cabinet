#!/bin/bash

git pull
npm install
node_modules/.bin/bower install
node_modules/.bin/brunch build -P
grunt
