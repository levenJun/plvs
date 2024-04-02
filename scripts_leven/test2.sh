#!/bin/bash

echo "cur_shell is ${BASH_SOURCE[0]}--------------"

#读取一些配置
BaseDir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/ #需要取绝对路径,不要搞相对路径!
source ${BaseDir}/common/s0_runtime_cfg.sh
source ${BaseDir}/common/s0_bash_utils.sh

# source $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/common/s0_runtime_cfg.sh

# source $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/common/s0_bash_utils.sh

echo "CONFIG_FILE_PATH=${CONFIG_FILE_PATH}"
echo "CurTime=${CurTime}"
echo "CurDir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

read_config_by_file ${BaseDir}/${CONFIG_FILE_PATH}
echo "test2.sh IMAGE_NAME:${IMAGE_NAME}.."
echo "test2.sh IMAGE_VERSION:${IMAGE_VERSION}.."