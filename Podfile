install! 'cocoapods', :warn_for_unused_master_specs_repo => false
use_frameworks!

def all_pods
  pod 'SDWebImageSwiftUI', :path => './'
  pod 'SDWebImageWebPCoder'
  pod 'SDWebImageSVGCoder'
  pod 'SDWebImagePDFCoder'
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