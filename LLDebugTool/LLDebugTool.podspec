Pod::Spec.new do |s|
  s.name                = "LLDebugTool"
  s.version             = "1.3.1"
  s.summary             = "LLDebugTool is a debugging tool for developers and testers that can help you analyze and manipulate data in non-xcode situations."
  s.homepage            = "https://github.com/HDB-Li/LLDebugTool"
  s.license             = "MIT"
  s.author              = { "HDB-Li" => "llworkinggroup1992@gmail.com" }
  s.social_media_url    = "https://github.com/HDB-Li"
  s.platform            = :ios, "8.0"
  s.source              = { :git => "https://github.com/HDB-Li/LLDebugTool.git", :tag => s.version }
  s.requires_arc        = true
  s.public_header_files = "LLDebugTool/LLDebug.h", "LLDebugTool/DebugTool/*.h"
  s.source_files	    = "LLDebugTool/**/*.{h,m}"
  s.resources		    = "LLDebugTool/**/*.{xib,storyboard,bundle}"
  s.frameworks          = "Foundation", "UIKit", "Photos", "SystemConfiguration", "CoreTelephony", "QuickLook"
  s.dependency            "FMDB", "~> 2.0"

end
