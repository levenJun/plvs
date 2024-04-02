#!/bin/bash

set -e

#替换源

#获取当前系统版本信息, attention:这一步可能会卡网
apt update
apt install lsb-release -y
curLsbRelease=$(lsb_release -cs)

#最开始不支持https的源:需要先用http的源,并安装证书
echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${curLsbRelease} main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${curLsbRelease}-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${curLsbRelease}-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${curLsbRelease}-security main restricted universe multiverse" >> /etc/apt/sources.list

apt-get update && \
    apt-get install --reinstall ca-certificates -y && \
    rm -rf /var/lib/apt/lists/*

#替换回https的源
echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${curLsbRelease} main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${curLsbRelease}-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${curLsbRelease}-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${curLsbRelease}-security main restricted universe multiverse" >> /etc/apt/sources.list

apt update