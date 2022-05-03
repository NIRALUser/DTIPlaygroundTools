#!/bin/bash

mkdir /work/src/build
cd /work/src/build
cmake ..
make
if [ $? -eq 0 ]; then
  mkdir -p ../dist
  tar cvfz ../dist/dtiplayground-tools.tar.gz  -C ../build/DTIPlaygroundTools-install dtiplayground-tools
fi