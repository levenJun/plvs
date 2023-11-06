#!/bin/bash
###
 # @Author: leven
 # @LastEditors: leven
 # @Description: 在docker环境下运行plvs
### 

echo "run_plvs_in_docker\n"

set -e
# set -v

#读取一些配置
BaseDir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")") #需要取绝对路径,不要搞相对路径!
source ${BaseDir}/common/s0_runtime_cfg.sh
source ${BaseDir}/common/s0_bash_utils.sh

#plvs源码根目录
PLVS_SRC_ROOT=${BaseDir}/..
PLVS_SRC_ROOT=$(readlink -f $PLVS_SRC_ROOT)  # this reads the actual path if a symbolic directory is used

read_config_by_file ${BaseDir}/${CONFIG_FILE_PATH}
echo "IMAGE_NAME:${IMAGE_NAME}.."
echo "IMAGE_VERSION:${IMAGE_VERSION}.."

#支持docker内的图形界面显示
xhost +

BUILD_IMAGE=${IMAGE_NAME}:${IMAGE_VERSION}
# BUILD_CONTAINER=${IMAGE_NAME}_${CurTime}
BUILD_CONTAINER=${IMAGE_NAME}_container_for_build

echo "PLVS_SRC_ROOT:${PLVS_SRC_ROOT}"

sudo docker run --rm -it --name ${BUILD_CONTAINER} \
         --volume /etc/localtime:/etc/localtime:ro \
         --volume /tmp/.X11-unix:/tmp/.X11-unix \
         -e DISPLAY=$DISPLAY -e GDK_SCALE -e GDK_DPI_SCALE \
         --volume ${PLVS_SRC_ROOT}:${PLVS_SRC_ROOT} \
         ${BUILD_IMAGE}  \
         /bin/bash \
        -c "cd ${PLVS_SRC_ROOT}"

#只是进入了docker里面,要运行plvs的demo程序,请自己按需求执行对应的 Scripts/run_xxx.sh