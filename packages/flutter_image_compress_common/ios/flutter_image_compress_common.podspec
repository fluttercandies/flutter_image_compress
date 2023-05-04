Pod::Spec.new do |s|
  s.name             = 'flutter_image_compress_common'
  s.version          = '1.0.0'
  s.summary          = 'Compress image with native Objective-C with faster speed.'
  s.description      = <<-DESC
Compress image with native Objective-C with faster speed.
                       DESC
  s.homepage         = 'http://github.com/fluttercandies/flutter_image_compress'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'fluttercandies' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.ios.deployment_target = '9.0'

  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'

  s.dependency 'Flutter'
  s.dependency 'Mantle'
  s.dependency 'SDWebImage'
  s.dependency 'SDWebImageWebPCoder'
end
