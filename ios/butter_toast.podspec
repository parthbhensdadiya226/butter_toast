#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint butter_toast.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'butter_toast'
  s.version          = '0.1.0'
  s.summary          = 'Reads the app icon for butter_toast.'
  s.description      = <<-DESC
Reads the app icon so butter_toast can show it in toasts.
                       DESC
  s.homepage         = 'https://github.com/parthbhensdadiya226/butter_toast'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Parth Bhensdadiya' => 'parthbhensdadiya7@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'butter_toast/Sources/butter_toast/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'butter_toast_privacy' => ['butter_toast/Sources/butter_toast/PrivacyInfo.xcprivacy']}
end
