
Pod::Spec.new do |s|
  s.name             = 'WkBridgeSwift'
  s.version          = '0.0.3'
  s.summary          = '简化wkwebview和前端通信交互的框架'
  s.description      = <<-DESC
  一个swift版本的简化wkwebview和前端通信交互的框架
                       DESC
  s.homepage         = 'https://github.com/1575792978@qq.com/WkBridgeSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'JyHiting' => '1575792978@qq.com' }
  s.source           = { :git => 'https://github.com/JyHiting/WkBridgeSwift.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'Source/*.swift'
  s.swift_versions = ['5.1', '5.2', '5.3']
  s.frameworks = 'WebKit'
  
end
