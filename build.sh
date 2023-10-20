#!/bin/sh

# https://discourse.jupyter.org/t/debugger-warning-it-seems-that-frozen-modules-are-being-used-python-3-11-0/16544
export PYDEVD_DISABLE_FILE_VALIDATION=1

# Build the book part:
jb build --path-output . content/

# Copy over CSV files, retaining the paths:
echo Copying CSV files from the content folder to the _build: 
cd content 
find reports -name "*.csv" -exec cp -v {} ../_build/html/{} \;
cd -