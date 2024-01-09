#!/bin/bash
# pathDatasetTUM_VI='/media/delljun/Bubby/data2/datasets/12-910-debug/1-/2023_11_17_17_26_30' #Example, it is necesary to change it by the dataset path
pathDatasetTUM_VI='/media/delljun/Bubby/data2/datasets/12-910-debug/1-/2023_11_17_17_10_28' #Example, it is necesary to change it by the dataset path

time=$(date "+%Y%m%d%H%M%S")

#------------------------------------
# Stereo-Inertial Examples

echo "Launching Room 6 with Stereo-Inertial sensor"
./Examples_Test/Stereo-Inertial/stereo_inertial_test_vi Vocabulary/ORBvoc.txt Examples_Test/Stereo-Inertial/TUM_512_test1.yaml "$pathDatasetTUM_VI" 2>&1 | tee -a log/log_${time}.txt
