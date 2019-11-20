#!/usr/bin/env bash
#######################################################################
#Author: kellanfan
#Created Time : Tue 28 Aug 2018 09:39:17 AM CST
#File Name: initos.sh
#Description:
#######################################################################

#######variable#########
SCRIPT=$(readlink -f $0)
CWD=$(dirname $SCRIPT)
DATA_DIR=$CWD/data
CONF_DIR=$CWD/conf
. $CONF_DIR/common.conf
log_file=/var/log/initos.log
########################
function Usage() {
    echo "$0 [common|shadow]"
    echo "  common: 普通模式安装"
    echo "  shadow: 翻墙模式安装"
    echo "Example: $0 common"
    echo "Example: $0 shadow"
}

function check_network() {
    echo "===check_network==="
    ping -c 1 -w 3 www.baidu.com > /dev/null
    if [ $? -ne 0 ];then
        exit 1
    fi
}

function update_ssh() {
    echo "===update ssh config==="
    if [ -d /root/.ssh ];then
        rm -rf /root/.ssh
    fi
    cp -r $DATA_DIR/ssh /root/.ssh
    sed -i "/^Port/s/22/${ssh_port}/" /etc/ssh/sshd_config
    sed -i '/^#PasswordAuthentication/a\PasswordAuthentication no' /etc/ssh/sshd_config
    service ssh reload
}

#update apt
function update_apt() {
    echo "===update apt repo==="
    local os_version=$(cat /etc/issue|awk '{print $2}'|cut -d'.' -f 1)
    cp /etc/apt/sources.list /etc/apt/sources.list-bak
    if [ "$os_version" == '14' ];then
        cp $DATA_DIR/sources.list-14 /etc/apt/sources.list
    elif [ "$os_version" == "16" ];then
        cp $DATA_DIR/sources.list-16 /etc/apt/sources.list
    elif [ "$os_version" == "18" ];then
        cp $DATA_DIR/sources.list-18 /etc/apt/sources.list
    fi
    apt-get clean; apt-get autoclean;
    apt-get update
}

#update env
function update_env() {
    echo "===update env==="
    cat <<EOF >> /root/.bashrc
PS1="\u@\[\e[1;93m\]\h\[\e[m\]:\w\\$\[\e[m\] "
HISTTIMEFORMAT="%F %T `whoami` "
export PYTHONDONTWRITEBYTECODE=False
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh
EOF
}

function update_vim() {
    echo "===update vimrc==="
    cp ${DATA_DIR}/vimrc ~/.vimrc
}

function install_package_common() {
    #pip install
    #pip install --upgrade pip
    pip install virtualenv
    pip install virtualenvwrapper
}

function install_package_1() {
    #install package
    echo "===install packages==="
    # install python 3.8.0
    #wget https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz
    #tar zxf ${DATA_DIR}/Python-3.8.0.tgz -C /tmp/
    #cd /tmp/Python-3.8.0
    #apt-get install -y -qq build-essential libncursesw5-dev libgdbm-dev libc6-dev zlib1g-dev libsqlite3-dev tk-dev libssl-dev openssl libffi-dev libbz2-dev
    #./configure
    #make && sudo make install
    
    apt-get install -y -qq vim openssh-server git python-pip python3-pip ipython3 ctags
    curl -sSL https://get.daocloud.io/docker | sh
    install_package_common
}

function install_package_2() {
    echo "===install packages==="
    apt-get install -y -qq unzip openssh-server python-pip python3-pip
    install_package_common
}

function init_shadownsocks() {
    echo "===install shadowsocks==="
    pip3 install shadowsocks
    if [ $? -ne 0 ];then
        tar zxf ${DATA_DIR}/shadowsocks-2.8.2.tar.gz -C /tmp
        cd /tmp/shadowsocks-2.8.2/
        python3 setup.py install
    fi
	if [ ! -d /etc/shadowsocks ];then
		mkdir /etc/shadowsocks
	fi
    cp ${DATA_DIR}/config.json /etc/shadowsocks/
    /usr/local/bin/ssserver -c /etc/shadowsocks/config.json -k Zhu88jie -d start
    sed -i "/^exit/i\/usr/local/bin/ssserver -c /etc/shadowsocks/config.json -k Zhu88jie -d start" /etc/rc.local
}

function log() {
    msg=$*
    DATE=$(date +'%Y-%m-%d %H:%M:%S')
    echo "${DATE} ${msg}" >> ${log_file}
}

function SafeExec() {
    local cmd=$1
    echo -n "Execing the step [${cmd}]..."
    log "Execing the step [${cmd}]..."
    ${cmd} >>${log_file} 2>&1
    if [ $? -eq 0 ];then
        echo -n "OK." && echo ""
        log "Exec the step [${cmd}] OK."
    else
        echo -n "Error!" && echo ""
        log "Exec the function [${cmd}] Error!"
        exit 1
    fi
}

function main() {
    echo "===初始化系统 v0.1==="

    if [ `id -u` -ne 0 ];then
        echo "Not Root!!!"
        exit 1
    fi
    if [ $# -ne 1 ];then
        Usage
        exit 1
    fi
	if [[ "x$1" == "x-h" ]] || [[ "x$1" == "x--help" ]]; then
    	Usage
    	exit 1
	fi

    SafeExec check_network

    if [[ "x$1" == "xcommon" ]];then
        echo "===begin to common mode==="
        log "===begin to common mode==="
        SafeExec update_apt
        SafeExec install_package_1
        SafeExec update_vim
        SafeExec update_ssh
        SafeExec update_env
    elif [[ "x$1" == "xshadow" ]];then
        echo "===begin to shadow mode==="
        log "===begin to shadow mode==="
        SafeExec update_apt
        SafeExec install_package_2
        SafeExec update_ssh
        SafeExec init_shadownsocks
        SafeExec update_env
    else
        Usage
        exit
    fi
    echo "Done."
}

main $1