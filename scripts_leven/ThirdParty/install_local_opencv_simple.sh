#!/usr/bin/env bash

###
 # @Author: leven
 # @LastEditors: leven
 # @Description: opencv简单安装方式:1)用本地zip源码包,不走git下载;2)不开cuda,(本机上没有显卡)
### 

# ====================================================

set -e

# #加载一些配置公共配置项目
# source $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../common/s0_runtime_cfg.sh

# source $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../common/s0_bash_utils.sh

echo "cur_shell is ${BASH_SOURCE[0]}--------------"

function check_package(){
    package_name=$1
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $package_name |grep "install ok installed")
    #echo "checking for $package_name: $PKG_OK"
    if [ "" == "$PKG_OK" ]; then
      #echo "$package_name is not installed"
      echo 1
    else
      echo 0
    fi
}

#读取一些配置
BaseDir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../ #需要取绝对路径,不要搞相对路径!
SCRIPT_DIR=${BaseDir}/..
SCRIPT_DIR=$(readlink -f $SCRIPT_DIR)  # this reads the actual path if a symbolic directory is used

source ${BaseDir}/common/s0_runtime_cfg.sh
source ${BaseDir}/common/s0_bash_utils.sh

print_blue  "Configuring and building Thirdparty/opencv ..."

read_config_by_file ${BaseDir}/${CONFIG_FILE_PATH}
print_blue "IMAGE_NAME:${IMAGE_NAME}.."
print_blue "IMAGE_VERSION:${IMAGE_VERSION}.."
print_blue "OPENCV_LOCAL_INSTALL_DIR:${OPENCV_LOCAL_INSTALL_DIR}.."


INSTALL_PREFIX=${SCRIPT_DIR}/${OPENCV_LOCAL_INSTALL_DIR}
print_blue "INSTALL_PREFIX=${INSTALL_PREFIX}"
export OPENCV_VERSION="4.8.0"   # 4.7.0 4.3.0 4.2.0 4.0.0 3.4.6 3.4.4 3.4.3 3.4.2 3.4.1 

if [ ! -f ${INSTALL_PREFIX}/lib/libopencv_core.so ]; then
  echo "${INSTALL_PREFIX}/lib/libopencv_core.so is not existed!"
else
  echo "${INSTALL_PREFIX}/lib/libopencv_core.so is existed!"
fi


if [ ! -f ${INSTALL_PREFIX}/lib/libopencv_core.so ]; then

    cd ${BaseDir}/ThirdParty/
    TARFILE=opencv-${OPENCV_VERSION}
    TARFILE_PACK=${TARFILE}.zip
    if [ ! -f "./$TARFILE_PACK" ]; then
      echo 'Cannot find opencv target file:'./${TARFILE_PACK}
      exit -1
    fi
    unzip ${TARFILE_PACK}
    mv ${TARFILE} opencv


    TARFILE_CONTRIB=opencv_contrib-${OPENCV_VERSION}
    TARFILE_CONTRIB_PACK=${TARFILE_CONTRIB}.zip
    if [ ! -f "./$TARFILE_CONTRIB_PACK" ]; then
      echo 'Cannot find opencv target file:'${TARFILE_CONTRIB_PACK}
      exit -1
    fi
    unzip ${TARFILE_CONTRIB_PACK}
    TARFILE_CONTRIB_PATH="`pwd`/${TARFILE_CONTRIB}"

    echo "TARFILE_CONTRIB_PATH=$TARFILE_CONTRIB_PATH.."

    version=$(lsb_release -a 2>&1)  # ubuntu version 

  #预安装依赖库
    sudo apt-get update
    sudo apt-get install -y pkg-config libglew-dev libtiff5-dev zlib1g-dev libjpeg-dev libeigen3-dev libtbb-dev libgtk2.0-dev libopenblas-dev
    sudo apt-get install -y software-properties-common

        if [[ $version == *"22.04"* ]] ; then
            sudo apt install -y libtbb-dev libeigen3-dev 
            sudo apt install -y zlib1g-dev libjpeg-dev libwebp-dev libpng-dev libtiff5-dev 
            sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"  # for libjasper-dev 
            sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32 # for libjasper-dev 
            sudo apt install -y libjasper-dev
            sudo apt install -y libv4l-dev libdc1394-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev yasm \
                                    libopencore-amrnb-dev libopencore-amrwb-dev libxine2-dev            
        fi
        if [[ $version == *"20.04"* ]] ; then
            sudo apt install -y libtbb-dev libeigen3-dev 
            sudo apt install -y zlib1g-dev libjpeg-dev libwebp-dev libpng-dev libtiff5-dev 
            sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"  # for libjasper-dev 
            sudo apt install -y libjasper-dev
            sudo apt install -y libv4l-dev libdc1394-22-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev yasm \
                                    libopencore-amrnb-dev libopencore-amrwb-dev libxine2-dev            
        fi
        if [[ $version == *"18.04"* ]] ; then
            sudo apt-get install -y libpng-dev 
            sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"  # for libjasper-dev 
            sudo apt-get install -y libjasper-dev
        fi
        if [[ $version == *"16.04"* ]] ; then
            sudo apt-get install -y libpng12-dev libjasper-dev 
        fi        

    DO_INSTALL_FFMPEG=$(check_package ffmpeg)
    if [ $DO_INSTALL_FFMPEG -eq 1 ] ; then
      echo "installing ffmpeg and its dependencies"
      sudo apt-get install -y libavcodec-dev libavformat-dev libavutil-dev libpostproc-dev libswscale-dev 
    fi


#正式准备编译

    echo "entering opencv"
    cd opencv
    mkdir -p build
    mkdir -p install
    cd build
    echo "I am in "$(pwd)
    machine="$(uname -m)"
    if [ "$machine" == "x86_64" ]; then
		# standard configuration 
        echo "building x86_64 config"
        # as for the flags and consider this nice reference https://gist.github.com/raulqf/f42c718a658cddc16f9df07ecc627be7
        cmake \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
          -DOPENCV_EXTRA_MODULES_PATH="${TARFILE_CONTRIB_PATH}/modules" \
          -DWITH_QT=ON \
          -DWITH_GTK=ON \
          -DWITH_OPENGL=ON \
          -DWITH_TBB=ON \
          -DWITH_V4L=ON \
          -DWITH_CUDA=OFF \
          -DWITH_CUBLAS=OFF \
          -DWITH_CUFFT=OFF \
          -DCUDA_FAST_MATH=OFF \
          -DWITH_CUDNN=OFF \
          -DOPENCV_DNN_CUDA=OFF \
          -DBUILD_opencv_cudacodec=OFF \
          -DENABLE_FAST_MATH=1 \
          -DBUILD_NEW_PYTHON_SUPPORT=ON \
          -DBUILD_DOCS=OFF \
          -DBUILD_TESTS=OFF \
          -DBUILD_PERF_TESTS=OFF \
          -DINSTALL_PYTHON_EXAMPLES=OFF \
          -DINSTALL_C_EXAMPLES=OFF \
          -DBUILD_EXAMPLES=OFF \
          -DOPENCV_ENABLE_NONFREE=ON \
          -DBUILD_opencv_java=OFF \
          -DBUILD_opencv_python3=ON ..
    else
        # Nvidia Jetson aarch64
        echo "building NVIDIA Jetson config"
        cmake \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX="`pwd`/../install" \
          -DOPENCV_EXTRA_MODULES_PATH="`pwd`/../opencv_contrib-$OPENCV_VERSION/modules" \
          -DWITH_QT=ON \
          -DWITH_GTK=OFF \
          -DWITH_OPENGL=ON \
          -DWITH_TBB=ON \
          -DWITH_V4L=ON \
          -DWITH_CUDA=ON \
          -DWITH_CUBLAS=ON \
          -DWITH_CUFFT=ON \
          -DCUDA_FAST_MATH=ON \
          -DCUDA_ARCH_BIN="6.2" \
          -DCUDA_ARCH_PTX="" \
          -DBUILD_opencv_cudacodec=OFF \
          -DENABLE_NEON=ON \
          -DENABLE_FAST_MATH=ON \
          -DBUILD_NEW_PYTHON_SUPPORT=ON \
          -DBUILD_DOCS=OFF \
          -DBUILD_TESTS=OFF \
          -DBUILD_PERF_TESTS=OFF \
          -DINSTALL_PYTHON_EXAMPLES=OFF \
          -DINSTALL_C_EXAMPLES=OFF \
          -DBUILD_EXAMPLES=OFF \
          -Wno-deprecated-gpu-targets ..
    fi
    make -j8
    make install 
    
    # sudo rm -r opencv 
    # sudo rm -r ${TARFILE_CONTRIB}
fi

cd ${SCRIPT_DIR}
echo "...done with opencv"
