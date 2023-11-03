#!/bin/bash
###
 # @Author: leven
 # @LastEditors: leven
 # @Description: 构建 编译运行 程序 的image
### 

echo "build_docker_image\n"

set -e
# set -v

#读取一些配置
BaseDir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")") #需要取绝对路径,不要搞相对路径!
source ${BaseDir}/common/s0_runtime_cfg.sh
source ${BaseDir}/common/s0_bash_utils.sh

read_config_by_file ${BaseDir}/${CONFIG_FILE_PATH}
echo "IMAGE_NAME:${IMAGE_NAME}.."
echo "IMAGE_VERSION:${IMAGE_VERSION}.."

#支持docker内的图形界面显示
sudo apt-get install x11-xserver-utils
xhost +

#正常完整的:ubuntu20下的docker环境构建
Dockerfile="s_2_1_Dockerfile_ub20_ros_plvs_detatch"

sudo docker build -f ${Dockerfile} -t ${IMAGE_NAME}:${IMAGE_VERSION} . 

echo "build image success: ${IMAGE_NAME}:${IMAGE_VERSION}"

sudo docker images 