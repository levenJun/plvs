在docker环境下编译运行plvs

## 构建环境image

s2_build_docker_image.sh

## 编译plvs

(如果有一些残留的编译缓存影响编译过程的,可以先在plvs源码根目录下执行 clean.sh)

s3_build_plvs_in_docker.sh

plvs源码根目录从docker外部映射到docker内部了,docker中编译plvs结果都缓存docker外部的工程目录下

## 运行

s4_run_plvs_in_docker.sh

只是借助脚本进入了docker, 要运行plvs的demo程序,还需要自己在docker中自己按需执行对应的run脚本

目前可以在docker内部执行plvs程序,也可以执行并显示时钟程序,但是执行plvs程度并显示slam图像报错.(留待解决)
