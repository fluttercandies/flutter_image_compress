#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_image_compress_macos.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_image_compress_macos'
  s.version          = '1.0.0'
  s.summary          = 'Flutter image compress for macOS'
  s.description      = <<-DESC
  Flutter image compress for macOS
                       DESC
  s.homepage         = 'https://github.com/fluttercandies/flutter_image_compress'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Caijinglong' => 'cjl_spy@163.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.15'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
