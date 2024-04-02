#!/bin/bash

# a collection of bash utils 


#读取一些配置:config.txt


function read_config_by_file(){
    local confg_file_path=$1

    if [ -e ${confg_file_path} ]; then
        IMAGE_NAME=$(grep 'ImageName=' ${confg_file_path}  | grep -vE "^(//|#)" | awk -F'=' '{print $2}')
        IMAGE_VERSION=$(grep 'ImageVersion=' ${confg_file_path} | grep -vE "^(//|#)" | awk -F'=' '{print $2}')
        OPENCV_LOCAL_INSTALL_DIR=$(grep 'OpencvLocalInstallDir=' ${confg_file_path} | grep -vE "^(//|#)" | awk -F'=' '{print $2}')        
    fi
    if [ -z $IMAGE_NAME ]; then
        IMAGE_NAME="ub28"
        echo "cfg IMAGE_NAME is empty, use default:$IMAGE_NAME"
    fi
    if [ -z $IMAGE_VERSION ]; then
        IMAGE_VERSION="0.8.3"
        echo "cfg IMAGE_VERSION is empty, use default:$IMAGE_VERSION"
    fi
    if [ -z $OPENCV_LOCAL_INSTALL_DIR ]; then
        OPENCV_LOCAL_INSTALL_DIR=Thirdparty/opencv/install
        echo "cfg OPENCV_LOCAL_INSTALL_DIR is empty, use default:$OPENCV_LOCAL_INSTALL_DIR"
    fi    
}

# function get_cur_dir(){
#     # 获取当前shell文件的绝对路径
#     local curDir=$(pwd)
#     return curDir   
# }

#不要调此函数,自己在shell中手动调用实时获取
# function get_cur_dir2(){
#     return $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
# }

function print_blue(){
	printf "\033[34;1m"
	printf "$@ \n"
	printf "\033[0m"
}

function print_red(){
	printf "\033[31;1m"
	printf "$@ \n"
	printf "\033[0m"
}