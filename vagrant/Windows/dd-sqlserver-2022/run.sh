#!/bin/bash

if [[ $(arch) == "arm64" ]]; then
  source ~/.sandbox.azure.sh
  echo "Running VAGRANT_VAGRANTFILE=Vagrantfile.arm64 vagrant $1"
  VAGRANT_VAGRANTFILE=Vagrantfile.arm64 vagrant $1
  if [[ $1 != "destroy" ]]; then
    echo "Make sure to destroy the box once you are done!"
  fi
else
  echo "Running VAGRANT_VAGRANTFILE=Vagrantfile.intel vagrant $1"
  VAGRANT_VAGRANTFILE=Vagrantfile.intel vagrant $1
fi