#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint suprsend_flutter_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'suprsend_flutter_sdk'
  s.version          = '2.3.0'
  s.summary          = 'A plugin to provide suprsend sdk functionality on the flutter applications'
  s.description      = <<-DESC
  A plugin to provide suprsend sdk functionality on the flutter applications
                       DESC
  s.homepage         = 'https://www.suprsend.com/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'SuprSend Developers' => 'support@suprsend.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency "SuprsendCore", "1.0.5"
  s.dependency "SuprSendSdk", "1.0.4"
  s.platform = :ios
  s.ios.deployment_target = "13.0"
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
