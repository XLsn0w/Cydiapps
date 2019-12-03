
##  一、写上基本的防护，内部使用hook，外部没有hook
### 1、新建工程：基本防护，写个简单的页面
![image.png](https://upload-images.jianshu.io/upload_images/1013424-6234f137c362e7dd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

代码如下：
![image.png](https://upload-images.jianshu.io/upload_images/1013424-7b711b4665a4aac6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
### 2、需求：在外部hook btnClick2,在内部hook btnClick1,需要保证的是在外部hook btnClick2无效，在内部hook btnClick1生效。

### 3、拖入fishhook代码，新建hookMgr类
```
//专门HOOK
+(void)load{
    //内部用到的交换代码
    Method old = class_getInstanceMethod(objc_getClass("ViewController"), @selector(btnClick1:));
    Method new = class_getInstanceMethod(self, @selector(click1Hook:));
    method_exchangeImplementations(old, new);
    
    //在交换代码之前，把所有的runtime代码写完 
    
    //基本防护
    struct rebinding bd;
    bd.name = "method_exchangeImplementations";
    bd.replacement=myExchang;
    bd.replaced=(void *)&exchangeP;
    
    struct rebinding rebindings[]={bd};
    rebind_symbols(rebindings, 1);
}

//保留原来的交换函数
void (* exchangeP)(Method _Nonnull m1, Method _Nonnull m2);

//新的函数
void myExchang(Method _Nonnull m1, Method _Nonnull m2){
    NSLog(@"检测到了hook");
}
-(void)click1Hook:(id)sender{
    NSLog(@"原来APP的hook保留");
}
```
说明：
* 在做防护之前，先把自己内部需要runtime交换的代码写完，比如开放btnClick1给自己内部去hook,其他的hook则禁止
* 使用fishhook hook method_exchangeImplementations方法，这样当外部使用method_exchangeImplementations方法时，让它失效

### 4、运行，分别点击按钮1和按钮2，此时内部hook了btnClick1方法，外部暂时没有hook任何方法
![image.png](https://upload-images.jianshu.io/upload_images/1013424-12884fb3e0172d6a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 二、准备ipa
### 1. 打包ipa
* 将基本防护.app拷贝出来
![image.png](https://upload-images.jianshu.io/upload_images/1013424-ce79352f52a8ed02.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
* 新建文件夹Payload，将基本防护.app拷贝到Payload文件夹中
* cd到Payload的上级目录，使用命令压缩,生成ipa
```zip -ry Hook.ipa Payload```

## 三、外部hook,注入代码
### 1.新建工程：Hook基本防护
代码注入参考:[iOS逆向之代码注入(framework)](https://www.jianshu.com/p/b447ec564837)

前面在hookMgr中已经做了防护，不能交换btnClick2方法,那么我们写下hook btnClick2的代码来测试一下：
```
+(void)load
{
    Method old = class_getInstanceMethod(objc_getClass("ViewController"), @selector(btnClick2:));
    Method new = class_getInstanceMethod(self, @selector(click2Hook:));
    method_exchangeImplementations(old, new);
}
    
-(void)click2Hook:(id)sender{
    NSLog(@"btnClick2交换成功");
}

```
运行，分别点击按钮1，按钮2，发现btnClick2交换成功，**防护失败了**
![image.png](https://upload-images.jianshu.io/upload_images/1013424-2ead2dab17b1fb11.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 2.思考防护失败的原因
* 1.在基本防护工程里，hookMgr的load方法里加上```NSLog(@"hookMgr--Load");```
* 2.在ViewController的load方法里加上```NSLog(@"ViewController--Load");```
* 3.在AppDelegate的load方法里加上
```
+(void)load{
    NSLog(@"AppDelegate--Load");
}
```
* 4.编译基本防护工程重新运行，生成基本防护.app，重新打包
```zip -ry Hook.ipa Payload```
* 5.将Hook.ipa拷贝到Hook基本防护工程的APP文件夹里，打开Hook基本防护工程，在WJHook的load方法里加上，```NSLog(@"WJHook---load");```    然后运行
![image.png](https://upload-images.jianshu.io/upload_images/1013424-47fd7a3ea8bc9b89.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
发现WJHook(攻击方)是最早调用的，hookMgr(防护方)是最晚调用的，那么攻击方方法都交换成功了，你防护方才来防护，明显是没用。因此，上面的btnClick2方法仍然被外部交换了，hookMgr没起到防护的作用。

### 3.解决办法
#### 1.修改Complie Sources的顺序
* 修改前
![image.png](https://upload-images.jianshu.io/upload_images/1013424-f56f751173b2339e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![image.png](https://upload-images.jianshu.io/upload_images/1013424-e55669b2ebc6d96f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

* 修改后
![image.png](https://upload-images.jianshu.io/upload_images/1013424-881ddbc1526919b8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![image.png](https://upload-images.jianshu.io/upload_images/1013424-067ac3fd74b60cb2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 2.既然外部的动态库最先加载，那么防护方自己建立一个动态库
* 在基本防护工程里新建动态库antiHook
![image.png](https://upload-images.jianshu.io/upload_images/1013424-cc91b18f0638ddf0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
* 编译运行
![image.png](https://upload-images.jianshu.io/upload_images/1013424-d28be817aafa1e17.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
* 生成基本防护.app，重新打包```zip -ry Hook.ipa Payload```
* 将Hook.ipa拷贝到Hook基本防护工程的APP文件夹里

#### 3.打开Hook基本防护工程，运行
![image.png](https://upload-images.jianshu.io/upload_images/1013424-e739b4788bf8ad86.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
* 发现我们的防护hookMgr先执行，并且 检测到了hook
* 至此外部就不能通过hook “Method Swizzle”来交换btnClick2方法

### 4、弊端
* 如果hookMgr内部要交换方法，需要提前在hookMgr的内部写好交换代码,然后再做防护。
* 因为在内部是没有办法再进行hook了，所以有些三方库如果用了Method Swizzle，那么你要做的修改就比较多，需要将工程里用到的全部method_exchangeImplementations换成exchangeP
![image.png](https://upload-images.jianshu.io/upload_images/1013424-45cb0797d3a385ad.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

*  **如果用Cydia Substrate或者MonkeyDev来hook，依然能hook成功**

### 5、下面用MonkeyDev来举例：
#### 1、新建MonkeyDev工程MonkeyDemo,此过程需要先安装好[MonkeyDev](https://github.com/AloneMonkey/MonkeyDev)
![image.png](https://upload-images.jianshu.io/upload_images/1013424-218bf020ed65027f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 2、将防护的Hook.ipa拷贝到MonkeyDemo->TargetApp文件夹下
![image.png](https://upload-images.jianshu.io/upload_images/1013424-4b3829eb0364c79b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
* %hook ViewController 表示hook ViewController这个类
* -(void)btnClick2:(id) org 表示hook btnClick2这个方法
![image.png](https://upload-images.jianshu.io/upload_images/1013424-cfc95b6dfeb71dc1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

* hookMgr是最先加载的，但是MonkeyDev还是能hook成功
![image.png](https://upload-images.jianshu.io/upload_images/1013424-15e23c239445eb59.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 6、为什么MonkeyDev和Cydia Substrate能hook成功？
#### 1.首先了解Cydia Substrate的组成部分(MonkeyDev也是集成了Cydia Substrate)：
Cydia Substrate主要由3部分组成：
* 1.MobileHooker
   MobileHooker顾名思义用于HOOK。它定义一系列的宏和函数，底层调用objc的runtime和fishhook来替换系统或者目标应用的函数.
其中有两个函数:
  * MSHookMessageEx 主要作用于Objective-C方法
 ```void MSHookMessageEx(Class class, SEL selector, IMP replacement, IMP result)```
  * MSHookFunction 主要作用于C和C++函数
 ```void MSHookFunction(voidfunction,void* replacement,void** p_original)```

* 2.MobileLoader
   MobileLoader用于加载第三方dylib在运行的应用程序中。启动时MobileLoader会根据规则把指定目录的第三方的动态库加载进去，第三方的动态库也就是我们写的破解程序.

* 3.safe mode
   因为APP程序质量参差不齐崩溃再所难免，破解程序本质是dylib，寄生在别人进程里。 系统进程一旦出错，可能导致整个进程崩溃,崩溃后就会造成iOS瘫痪。所以CydiaSubstrate引入了安全模式,在安全模 式下所有基于CydiaSubstratede 的三方dylib都会被禁用，便于查错与修复。

#### 2. MSHookMessageEx底层调用objc的runtime和fishhook来替换系统或者目标应用的函数
在我们的防护代码中，只防护了method_exchangeImplementations方法，然而method_setImplementation和method_getImplementation并没有做防护，因此猜想Cydia Substrate就是通过这两个方法来hook的。
#### 3.实验
* 在基本防护2的工程中，增加对method_setImplementation和method_getImplementation的防护
![image.png](https://upload-images.jianshu.io/upload_images/1013424-de41f61033de252a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

* 编译生成基本防护.app,再次打包成Hook.ipa
* 将Hook.ipa拷贝到MonkeyDemo->TargetApp文件夹下
* 运行MonkeyDemo工程

![image.png](https://upload-images.jianshu.io/upload_images/1013424-a68277684d0832d4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
**如图，做到了防护MonkeyDev的hook,在检测到hook，强制退出APP**

> * 那么，上面的防护真的就无法破解了吗？
>答案当然是否定的，提供一个思路：
**通过修改MachO文件，在防护动态库之前调用hook的动态库，就能实现hook,因为你是在我hook成功之后才做的防护。**
> * 不过新手一般就破解不了上面的防护了。进攻和防护还需要不断学习！











