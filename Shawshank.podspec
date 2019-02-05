Pod::Spec.new do |s|
  s.name = 'Shawshank'
  s.version = '0.0.1'
  s.license = 'MIT'
  s.summary = 'Easy stubbing for network calls in unit tests'
  s.homepage = 'https://github.com/atetlaw/shawshank'
  s.authors = { 'Andrew Tetlaw' => 'andrew@tetlaw.id.au' }
  s.source = { :git => 'https://github.com/atetlaw/shawshank.git', :tag => s.version }
  s.source_files = 'Shawshank/*.swift'
  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'
end