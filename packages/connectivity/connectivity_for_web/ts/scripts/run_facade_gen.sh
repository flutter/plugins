#!/bin/bash

INDEX_PATH=node_modules/network-information-types/dist-types/index.d.ts
WORK_PATH=network_information_types.d.ts
DIST_PATH=dist

# Create dist if it doesn't exist already
mkdir -p $DIST_PATH

# Copy the input file(s) into our work path
cp $INDEX_PATH $WORK_PATH

# Run dart_js_facade_gen
dart_js_facade_gen $WORK_PATH --trust-js-types --generate-html --destination .

# Move output to the right place, and clean after yourself
mv *.dart $DIST_PATH
rm $WORK_PATH
