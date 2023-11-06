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
print_blue "Configuring and building Thirdparty/Pangolin ..."

cd Thirdparty
if [[ ! -f Pangolin/build/src/libpangolin.so && ! -f Pangolin/build/libpango_core.so ]]; then

    if [ -d Pangolin ]; then
        sudo rm -r Pangolin
    fi

	sudo apt-get install -y libglew-dev
	# git clone https://github.com/stevenlovegrove/Pangolin.git
    sudo cp ${BaseDir}/ThirdParty/Pangolin.zip ./
    unzip Pangolin.zip && sudo rm -r Pangolin.zip

    #git fetch --all --tags # to fetch tags 
    cd Pangolin
    #git checkout tags/v0.6
    git checkout fe57db532ba2a48319f09a4f2106cc5625ee74a9
    git apply ../pangolin.patch  # applied to commit fe57db532ba2a48319f09a4f2106cc5625ee74a9
    
    if [ -d build ]; then
        sudo rm -r build
    fi

    make_buid_dir

	cd build
	#cmake .. -DCMAKE_BUILD_TYPE=Release -DAVFORMAT_INCLUDE_DIR="" -DCPP11_NO_BOOST=ON $EXTERNAL_OPTION
	cmake .. -DCMAKE_INSTALL_PREFIX="`pwd`/../install" -DCMAKE_BUILD_TYPE=Release $EXTERNAL_OPTION    
	make -j 8
        make install     
fi
cd $SCRIPT_DIR