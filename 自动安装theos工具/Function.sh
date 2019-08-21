function_setport(){
    echo "-----------设置环境变量-----------"
    export THEOS=/opt/theos
    export OSldid=$THEOS/bin/ldid
    export OSdpkg=$THEOS/bin/dpkg-deb
}

function_installTheos(){
    clear
    echo "正在初始化环境下载Theos..."
    echo "如有提示Password，请输入系统登录密码。"

    # 下载安装theos，这个theos是本人已经修改过的，已经放入ldid，dpkg等
    sudo git clone https://github.com/bigsen/Theos.git $THEOS

    # 设置文件权限
    sudo chmod 777 $OSldid
    sudo chmod 777 $OSdpkg

    open $THEOS
}

function_dumpFile(){
    clear
    #!/bin/sh
    export dumpath=/usr/bin/class-dump
    clear
    if [ ! -f $dumpath ]
    then
    sudo cp class-dump /usr/bin/
    echo "拷贝class-dump完成"
    sudo chmod 777 $dumpath
    fi

    read -p "请输入APP的路径(可拖拽进来)： " appPath
    read -p "请输入输出目标文件夹的路径(可拖拽进来) ：" inputPath
    class-dump -s -S -H $appPath -o $inputPath
    open $inputPath
    echo "完成导出头文件"
}

function_didload(){
    clear
    function_setport
    echo "1, Install Theos"
    echo "2, Dump App"
    read -p "请输入您的选择:" branchNum
    case $branchNum in
    1)  function_installTheos
    ;;
    2)  function_dumpFile
    ;;
    *)  echo 'You do not select a number between 1 to 4'
    ;;
    esac
}