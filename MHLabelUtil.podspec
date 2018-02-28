Pod::Spec.new do |s|
  s.name             = 'MHLabelUtil'
  s.version          = '0.0.1'
  s.summary          = '扩展UILabel'
  s.homepage         = 'https://github.com/mansonhu/MHLabelUtil'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mansonhu' => 'mhx_work@163.com' }
  s.source           = { :git => 'https://github.com/mansonhu/MHLabelUtil.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'MHLabelUtil/Classes/**/*'
  s.requires_arc  = true
  # s.frameworks = 'CoreText'
end
