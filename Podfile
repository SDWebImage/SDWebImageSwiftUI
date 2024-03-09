install! 'cocoapods', :warn_for_unused_master_specs_repo => false
use_frameworks!

def all_pods
  pod 'SDWebImageSwiftUI', :path => './'
  pod 'SDWebImageWebPCoder'
  pod 'SDWebImageSVGCoder'
  pod 'SDWebImagePDFCoder'
  pod 'SDWebImageAVIFCoder'
  pod 'libavif', :subspecs => ['libdav1d']
end

def all_test_pods
  pod 'SDWebImageSwiftUI', :path => './'
end

example_project_path = 'Example/SDWebImageSwiftUI'
test_project_path = 'Example/SDWebImageSwiftUI'
workspace 'SDWebImageSwiftUI.xcworkspace'

target 'SDWebImageSwiftUIDemo' do
  project example_project_path
  platform :ios, '14.0'
  all_pods
end

target 'SDWebImageSwiftUIDemo-macOS' do
  project example_project_path
  platform :osx, '11.0'
  all_pods
end

target 'SDWebImageSwiftUIDemo-tvOS' do
  project example_project_path
  platform :tvos, '14.0'
  all_pods
end

target 'SDWebImageSwiftUIDemo-watchOS WatchKit Extension' do
  project example_project_path
  platform :watchos, '7.0'
  all_pods
end

# Test Project
target 'SDWebImageSwiftUITests' do
  project test_project_path
  platform :ios, '14.0'
  all_test_pods
end

target 'SDWebImageSwiftUITests macOS' do
  project test_project_path
  platform :osx, '11.0'
  all_test_pods
end

target 'SDWebImageSwiftUITests tvOS' do
  project test_project_path
  platform :tvos, '14.0'
  all_test_pods
end


# Inject macro during SDWebImage Demo and Tests
post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
    if target.product_name == 'SDWebImage'
      target.build_configurations.each do |config|
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = '$(inherited) SD_CHECK_CGIMAGE_RETAIN_SOURCE=1'
      end
    elsif target.product_name == 'SDWebImageSwiftUI'
      # Do nothing
    else
      target.build_configurations.each do |config|
        # Override the min deployment target for some test specs to workaround `libarclite.a` missing issue
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
        config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.11'
        config.build_settings['TVOS_DEPLOYMENT_TARGET'] = '9.0'
        config.build_settings['WATCHOS_DEPLOYMENT_TARGET'] = '2.0'
        config.build_settings['XROS_DEPLOYMENT_TARGET'] = '1.0'
      end
    end
  end
end
