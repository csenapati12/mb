#!/bin/bash

# stop the script on error

# set -e

# functions have to be defined before everything else

# read a given variable from a given file in
# usage: MY_VAR=$(read_var MY_VAR .env)

build_mode=$1
Release_Version=$2
job_name=$3

if [ $job_name == "job-name-test" ]
then
	echo "job-name-test"
  echo "job-name-test1"
  
elif [ $job_name == "job-name-test1" ]
then
	echo "job-name-test1"
  echo "job-name-test1"
else
	echo "Invalid job name."
fi



#set +e
