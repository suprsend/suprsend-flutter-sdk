#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint suprsend_flutter_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'suprsend_flutter_sdk'
  s.version          = '3.0.0'
  s.summary          = 'SuprSend Flutter SDK.'
  s.description      = <<-DESC
Flutter wrapper around the native SuprSend SDKs for user identification, event
tracking, user channels and push notifications.
                       DESC
  s.homepage         = 'https://www.suprsend.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'SuprSend' => 'tech@suprsend.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'SuprSendSwift', '~> 1.2'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
