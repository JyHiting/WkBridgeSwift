
Pod::Spec.new do |s|
  s.name             = 'WkBridgeSwift'
  s.version          = '0.0.8'
  s.summary          = '简化wkwebview和前端的通信交互，处理body丢失，提供截长图功能的一个轻量桥接框架'
  s.description      = <<-DESC
  简化wkwebview和前端的通信交互
  帮助处理body丢失问题
  提供截长图功能
                       DESC
  s.homepage         = 'https://github.com/JyHiting/WkBridgeSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'JyHiting' => '1575792978@qq.com' }
  s.source           = { :git => 'https://github.com/JyHiting/WkBridgeSwift.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'Source/*.swift'
  s.swift_versions = ['5.1', '5.2', '5.3']
  s.frameworks = 'WebKit'
end
