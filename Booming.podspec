#
# Be sure to run 'pod lib lint Booming.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Booming'
  s.version          = '1.0.0'
  s.summary          = 'Network Api Library.'
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  s.homepage         = 'https://github.com/yangKJ/RxNetworks'
  s.description      = 'https://github.com/yangKJ/RxNetworks/blob/master/README.md'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yangkejun' => 'yangkj310@gmail.com' }
  s.source           = { :git => 'https://github.com/yangKJ/RxNetworks.git', :tag => "#{s.version}" }
  s.social_media_url = 'https://juejin.cn/user/1987535102554472/posts'
  
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.13'
  s.swift_version    = '5.0'
  s.requires_arc     = true
  s.static_framework = true
  
  s.pod_target_xcconfig = {
    'SWIFT_WHOLE_MODULE_OPTIMIZATION' => 'YES',
    "OTHER_SWIFT_FLAGS[config=Debug]" => "-D DEBUG",
  }
  
  #s.default_subspec  = 'Core'
  
  s.subspec 'Core' do |xxx|
    s.source_files = 'Booming/*.swift'
    s.dependency 'Moya'
  end
  
  s.subspec 'AnimatedLoading' do |xxx|
    xxx.source_files = 'Plugins/AnimatedLoading/*.swift'
    xxx.dependency 'Booming/Core'
    xxx.dependency 'lottie-ios'
    xxx.ios.deployment_target = '11.0'
    xxx.osx.deployment_target = '10.15'
  end
  
  s.subspec 'Debugging' do |xxx|
    xxx.source_files = 'Plugins/Debugging/*.swift'
    xxx.dependency 'Booming/Core'
    xxx.pod_target_xcconfig = {
      'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'BOOMING_PLUGINGS_DEBUGGING',
      'GCC_PREPROCESSOR_DEFINITIONS' => 'BOOMING_PLUGINGS_DEBUGGING=1'
    }
  end
  
  s.subspec 'Cache' do |xxx|
    xxx.source_files = 'Plugins/Cache/*.swift'
    xxx.dependency 'Booming/Core'
    xxx.dependency 'CacheX', '~> 1.1.0'
  end
  
  s.subspec 'GZip' do |xxx|
    xxx.source_files = 'Plugins/GZip/*.swift'
    xxx.dependency 'Booming/Core'
  end
  
  s.subspec 'Shared' do |xxx|
    xxx.source_files = 'Plugins/Shared/*.swift'
    xxx.dependency 'Booming/Core'
    xxx.pod_target_xcconfig = {
      'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'BOOMING_PLUGINGS_SHARED',
      'GCC_PREPROCESSOR_DEFINITIONS' => 'BOOMING_PLUGINGS_SHARED=1'
    }
  end
  
  s.subspec 'Header' do |xxx|
    xxx.source_files = 'Plugins/Header/*.swift'
    xxx.dependency 'Booming/Core'
    xxx.pod_target_xcconfig = {
      'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'BOOMING_PLUGINGS_HTTPHEADER',
      'GCC_PREPROCESSOR_DEFINITIONS' => 'BOOMING_PLUGINGS_HTTPHEADER=1'
    }
  end
  
  s.subspec 'Files' do |xxx|
    xxx.source_files = 'Plugins/Files/*.swift'
    xxx.dependency 'Booming/Core'
    xxx.pod_target_xcconfig = {
      'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'BOOMING_PLUGINGS_DOWNLOAD_UPLOAD',
      'GCC_PREPROCESSOR_DEFINITIONS' => 'BOOMING_PLUGINGS_DOWNLOAD_UPLOAD=1'
    }
  end
  
  ################## -- ios插件系列 -- ##################
  s.subspec 'Loading' do |xxx|
    xxx.ios.source_files = 'Plugins/Loading/*.swift'
    xxx.dependency 'Booming/Core'
    xxx.ios.dependency 'MBProgressHUD'
  end
  
  s.subspec 'Warning' do |xxx|
    xxx.ios.source_files = 'Plugins/Warning/*.swift'
    xxx.dependency 'Booming/Core'
    xxx.ios.dependency 'MBProgressHUD'
    xxx.ios.pod_target_xcconfig = {
      'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'BOOMING_PLUGINGS_WARNING',
      'GCC_PREPROCESSOR_DEFINITIONS' => 'BOOMING_PLUGINGS_WARNING=1'
    }
  end
  
  s.subspec 'Indicator' do |xxx|
    xxx.ios.source_files = 'Plugins/Indicator/*.swift'
    xxx.dependency 'Booming/Core'
    xxx.ios.pod_target_xcconfig = {
      'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'BOOMING_PLUGINGS_INDICATOR',
      'GCC_PREPROCESSOR_DEFINITIONS' => 'BOOMING_PLUGINGS_INDICATOR=1'
    }
  end
  
end
