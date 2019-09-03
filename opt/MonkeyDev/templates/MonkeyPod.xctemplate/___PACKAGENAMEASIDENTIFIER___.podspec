Pod::Spec.new do |spec|
  spec.name             = "___PACKAGENAME___"                         #Pod的名字
  spec.version          = "1.0.0"                                     #版本号
  spec.summary          = "A example pod for MonkeyDev"
  spec.description      = <<-DESC                                     #Pod的描述
                          - A example pod for MonkeyDev
                        DESC

  spec.homepage         = "https://github.com/AloneMonkey/MonkeyDevPod"   #Pod的地址

  spec.license          = { :type => "BSD", :file => "LICENSE" }          #License
  spec.author           = { "AloneMonkey" => "liupeiqing1993@163.com" }   #作者
  spec.social_media_url = "http://weibo.com/xiaoqing28"                   #weibo
  spec.platform         = :ios, "8.0"                                     #平台、版本
  spec.source           = { :git => "https://github.com/AloneMonkey/MonkeyPod.git", :tag => spec.version.to_s }  #代码的git地址以及tag
  spec.source_files     = "___PACKAGENAME___/**/*.{h,m}"        #本地验证，表示当前目录以及子目录的所有h或m结尾的文件   如果发布到MonkeyPodSpecs需要填写git clone下来的对应的路径
  spec.public_header_files = "___PACKAGENAME___/___PACKAGENAME___.h"        #需要对外导出的头文件  此处为本地验证
  spec.requires_arc     = true                                       #ARC
  spec.pod_target_xcconfig = { "ONLY_ACTIVE_ARCH" => "NO", "HEADER_SEARCH_PATHS" => "/opt/MonkeyDev/include" }          #这个必须有，不要修改
end