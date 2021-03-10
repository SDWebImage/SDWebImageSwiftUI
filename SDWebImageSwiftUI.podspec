#
# Be sure to run `pod lib lint SDWebImageSwiftUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SDWebImageSwiftUI'
  s.version          = '2.0.2'
  s.summary          = 'SwiftUI Image loading and Animation framework powered by SDWebImage'

  s.description      = <<-DESC
SDWebImageSwiftUI is a SwiftUI image loading framework, which based on SDWebImage.
It brings all your favorite features from SDWebImage, like async image loading, memory/disk caching, animated image playback and performances.
                       DESC

  s.homepage         = 'https://github.com/SDWebImage/SDWebImageSwiftUI'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'DreamPiggy' => 'lizhuoli1126@126.com' }
  s.source           = { :git => 'https://github.com/SDWebImage/SDWebImageSwiftUI.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  s.tvos.deployment_target = '13.0'
  s.watchos.deployment_target = '6.0'

  s.source_files = 'SDWebImageSwiftUI/Classes/**/*', 'SDWebImageSwiftUI/Module/*.h'
  s.pod_target_xcconfig = {
    'SUPPORTS_MACCATALYST' => 'YES',
    'DERIVE_MACCATALYST_PRODUCT_BUNDLE_IDENTIFIER' => 'NO',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES'
  }

  s.weak_frameworks = 'SwiftUI', 'Combine'
  s.dependency 'SDWebImage', '~> 5.10'
  s.swift_version = '5.2'
end
