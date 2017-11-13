Pod::Spec.new do |s|
  s.name     = 'Pyrobase'
  s.version  = '1.1'
  s.summary  = 'An iOS lightweight wrapper for Firebase REST API'
  s.platform = :ios, '9.0'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage = 'https://github.com/mownier/pyrobase'
  s.author   = { 'Mounir Ybanez' => 'rinuom91@gmail.com' }
  s.source   = { :git => 'https://github.com/mownier/pyrobase.git', :tag => s.version.to_s }
  s.source_files = 'Pyrobase/*.swift'
  s.requires_arc = true
end
