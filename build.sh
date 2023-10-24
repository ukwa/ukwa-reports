#!/bin/bash

# https://discourse.jupyter.org/t/debugger-warning-it-seems-that-frozen-modules-are-being-used-python-3-11-0/16544
export PYDEVD_DISABLE_FILE_VALIDATION=1

# Build the book part:
jb build --path-output . content/

# Copy over CSV files, retaining the full paths:
echo Copying CSV files from the content folder to the _build: 
cd content 
find . -name "*.csv" -exec cp -v {} ../_build/html/{} \;
cd -

# Copy output to the OUTPUT_PATH if specified:
if [[ -z "${OUTPUT_PATH}" ]]; then
  echo No OUTPUT_PATH specified.
else
  echo Copying static site into '$OUTPUT_PATH'...
  mkdir -p $OUTPUT_PATH
  cp -v -r _build/html/* $OUTPUT_PATH
fi