#!/usr/bin/env bash
###
 # @Author: leven
 # @LastEditors: leven
 # @Description: 提前下载好了源码,还是需要在 build_thirdparty.sh 中调用执行
### 

# . config.sh  # source configuration file and utils 

set -e

BaseDir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../ #需要取绝对路径,不要搞相对路径!
source ${BaseDir}/common/s0_runtime_cfg.sh
source ${BaseDir}/common/s0_bash_utils.sh
SCRIPT_DIR=${BaseDir}/..
SCRIPT_DIR=$(readlink -f $SCRIPT_DIR)  # this reads the actual path if a symbolic directory is used
cd $SCRIPT_DIR # this brings us in the actual used folder (not the possibly symbolic one)
source $SCRIPT_DIR/config.sh

EXTERNAL_OPTION=$1
if [[ -n "$EXTERNAL_OPTION" ]]; then
    echo "external option: $EXTERNAL_OPTION" 
fi

print_blue '================================================'
print_blue "Configuring and building Thirdparty/g2o_new ..."

cd Thirdparty

if [[ ! -f g2o_new/install/lib/libg2o_core.so ]]; then

    if [ -d g2o_new ]; then
        sudo rm -r g2o_new
    fi

    sudo apt install -y libqglviewer-dev-qt5  # to build g2o_viewer 
	  # git clone https://github.com/RainerKuemmerle/g2o.git g2o_new
    sudo cp ${BaseDir}/ThirdParty/g2o_new.zip ./
    unzip g2o_new.zip && sudo rm -r g2o_new.zip
    #git fetch --all --tags # to fetch tags 
    cd g2o_new
    git checkout tags/20230223_git   
    git apply ../g2o.patch 

    if [ -d build ]; then
        sudo rm -r build
    fi
    make_buid_dir

	cd build
    G2O_OPTIONS="-DBUILD_WITH_MARCH_NATIVE=ON -DG2O_BUILD_EXAMPLES=OFF" 
    echo "compiling with options: $G2O_OPTIONS $EXTERNAL_OPTION" 
    cmake .. -DCMAKE_INSTALL_PREFIX="`pwd`/../install" -DCMAKE_BUILD_TYPE=Release $G2O_OPTIONS $EXTERNAL_OPTION
	  make -j 8
    make install 
fi 
cd $SCRIPT_DIR