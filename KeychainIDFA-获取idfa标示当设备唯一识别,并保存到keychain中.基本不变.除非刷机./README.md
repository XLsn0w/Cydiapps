KeychainIDFA
============

获取idfa标示当设备唯一识别,并保存到keychain中.基本不变.除非刷机.


### 测试数据

    //第一次:2d54d261-7bae-4014-8b81-3f9ff969b6e1
    //第二次:2d54d261-7bae-4014-8b81-3f9ff969b6e1
    //卸载app启动:2d54d261-7bae-4014-8b81-3f9ff969b6e1
    
    //delete之后:2b8d8afc-7f87-4c9c-ac73-ec64a89fc1a8
    //delete之后2次:2b8d8afc-7f87-4c9c-ac73-ec64a89fc1a8
    //delete之后卸载:2b8d8afc-7f87-4c9c-ac73-ec64a89fc1a8
    
    
### 使用方式
    
    //设置你idfa的Keychain标示,该标示相当于key,而你的IDFA是value
    //在KeychainIDFA.h中定义
    #define IDFA_STRING @"com.qixin.test.idfa"
    
    #import "KeychainIDFA.h"

    [KeychainIDFA IDFA]//获取IDFA
    
    [KeychainIDFA deleteIDFA]//删除Keychain中IDFA(一般不用)
