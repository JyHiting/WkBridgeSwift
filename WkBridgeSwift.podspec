
Pod::Spec.new do |s|
  s.name             = 'WkBridgeSwift'
  s.version          = '0.0.3'
  s.summary          = 'A short description of WkBridgeSwift.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/1575792978@qq.com/WkBridgeSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '1575792978@qq.com' => '1575792978@qq.com' }
  s.source           = { :git => 'https://github.com/1575792978@qq.com/WkBridgeSwift.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'Source/*.swift'
  s.frameworks = 'WebKit'
  
end
