#!/bin/bash

echo "cur_shell is ${BASH_SOURCE[0]}--------------"

# local curFileDir=`pwd`
# echo "test3 curFileDir=${curFileDir}"



#读取一些配置
BaseDir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/ #需要取绝对路径,不要搞相对路径!
source ${BaseDir}/common/s0_runtime_cfg.sh
source ${BaseDir}/common/s0_bash_utils.sh

${BaseDir}/test2.sh

${BaseDir}/test4/test4.sh

# source $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/common/s0_runtime_cfg.sh

# source $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/common/s0_bash_utils.sh

echo "test3 CONFIG_FILE_PATH=${CONFIG_FILE_PATH}"
echo "test3 CurTime=${CurTime}"
echo "test3 CurDir=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

