#!/usr/bin/env bash

#echo "usage: ./${0##*/} "

#SUFFIX="_old" # comment if you want to use the new example binaries

# DATASET_BASE_FOLDER="$HOME/Work/datasets/tum_vi_dataset" #Example, it is necesary to change it by the dataset path
DATASET_BASE_FOLDER="/media/delljun/Bubby/data2/datasets/TUM/" #Example, it is necesary to change it by the dataset path

#DATASET_NAME="dataset-magistrale1_512_16"
#DATASET_NAME="dataset-corridor1_512_16"
DATASET_NAME="dataset-room1_512_16"

#TUM_YAML="TUM-VI.yaml"
#TUM_YAML="TUM-VI_far.yaml"  # for outdoor envs 
TUM_YAML="TUM-VI_rectified.yaml"


#export DEBUG_PREFIX="gdb -ex run --args"  # uncomment this in order to debug with gdb
#export DEBUG_PREFIX="valkyrie "

# Single Session Example

RESULTS_LOG=$DATASET_NAME"_stereoi"
DATASET_TIMESTAMPS_DATA=../Examples$SUFFIX/Stereo-Inertial/TUM_TimeStamps/${DATASET_NAME:0:-3}".txt"  # remove the last 3 chars from dataset name
DATASET_IMU_DATA=../Examples$SUFFIX/Stereo-Inertial/TUM_IMU/${DATASET_NAME:0:-3}".txt" # remove the last 3 chars from dataset name

echo "Launching with Stereo-Inertial sensor"
$DEBUG_PREFIX ../Examples$SUFFIX/Stereo-Inertial/stereo_inertial_tum_vi$SUFFIX \
	../Vocabulary/ORBvoc.txt \
	../Examples$SUFFIX/Stereo-Inertial/$TUM_YAML \
	$DATASET_BASE_FOLDER/$DATASET_NAME"/mav0/cam0/data" \
	$DATASET_BASE_FOLDER/$DATASET_NAME"/mav0/cam1/data" \
	$DATASET_TIMESTAMPS_DATA \
	$DATASET_IMU_DATA \
	$RESULTS_LOG

echo RESULTS_LOG: $RESULTS_LOG

echo "------------------------------------"
echo "Evaluation of $DATASET_NAME trajectory with Stereo-Inertial sensor"
python evaluate_ate_scale.py $DATASET_BASE_FOLDER/$DATASET_NAME"/mav0/mocap0/data.csv" "f_"$RESULTS_LOG".txt" --plot "f_"$RESULTS_LOG".pdf"


./move_output_to_results.sh $RESULTS_LOG
