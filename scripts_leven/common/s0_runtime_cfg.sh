#!/bin/bash

# a collection of global cfgs

#读取一些配置
CONFIG_FILE_PATH="./config.txt"
CurTime=$(date +"%Y%m%d_%H%M%S")

# 不要把CurDir搞成全局的,要具体shell文件自己去实时获取!
# CurDir=$(pwd) 