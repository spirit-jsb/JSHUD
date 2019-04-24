Pod::Spec.new do |s|

    s.name             = 'JSHUD'
    s.version          = '1.2.0'
    s.summary          = '一个简便易用的自定义 Progress HUD 框架。'
  
    s.description      = <<-DESC
    一个简便易用的自定义 Progress HUD 框架，方便快捷的定制 HUD。
                         DESC
  
    s.homepage         = 'https://github.com/spirit-jsb/JSHUD'
  
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
  
    s.author           = { 'spirit-jsb' => 'sibo_jian_29903549@163.com' }
  
    s.swift_version = '5.0'
  
    s.ios.deployment_target = '9.0'
  
    s.source           = { :git => 'https://github.com/spirit-jsb/JSHUD.git', :tag => s.version.to_s }
    
    s.source_files = 'Sources/**/*.swift'
    
    s.requires_arc = true
    s.frameworks = 'UIKit', 'Foundation', 'QuartzCore', 'CoreGraphics'
  
  end