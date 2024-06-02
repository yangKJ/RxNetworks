#
# Be sure to run 'pod lib lint Booming.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Booming'
  s.version          = '1.0.4'
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
  s.cocoapods_version = '>= 1.4.0'
  
  s.pod_target_xcconfig = {
    'SWIFT_WHOLE_MODULE_OPTIMIZATION' => 'YES',
    "OTHER_SWIFT_FLAGS[config=Debug]" => "-D DEBUG",
  }
  
  #s.default_subspec  = 'Core'
  s.ios.source_files = 'Booming.h'
  
  s.subspec 'Core' do |ss|
    ss.source_files = 'Booming/*.swift'
    ss.dependency 'Moya'
    ss.framework = "Foundation"
  end
  
  ################## -- 插件系列 -- ##################
  s.subspec 'Plugins' do |xx|
    xx.subspec 'Lottie' do |xxx|
      xxx.source_files = 'Plugins/Lottie/*.swift'
      xxx.dependency 'Booming/Core'
      xxx.dependency 'lottie-ios'
      xxx.ios.deployment_target = '11.0'
      xxx.osx.deployment_target = '10.15'
    end
    
    xx.subspec 'Cache' do |xxx|
      xxx.source_files = 'Plugins/Cache/*.swift'
      xxx.dependency 'Booming/Core'
      xxx.dependency 'CacheX', '~> 1.1.0'
    end
    
    ## 无任何耦合和要求的插件
    xx.subspec 'Shared' do |xxx|
      xxx.source_files = 'Plugins/Shared/*.swift'
      xxx.dependency 'Booming/Core'
      xxx.pod_target_xcconfig = {
        'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'BOOMING_PLUGINGS_SHARED',
        'GCC_PREPROCESSOR_DEFINITIONS' => 'BOOMING_PLUGINGS_SHARED=1'
      }
    end
    
    ################## -- ios插件系列 -- ##################
    xx.subspec 'Loading' do |xxx|
      xxx.ios.source_files = 'Plugins/Loading/*.swift'
      xxx.dependency 'Booming/Core'
      xxx.ios.dependency 'MBProgressHUD'
    end
    
    xx.subspec 'Warning' do |xxx|
      xxx.ios.source_files = 'Plugins/Warning/*.swift'
      xxx.dependency 'Booming/Core'
      xxx.ios.dependency 'MBProgressHUD'
      xxx.ios.pod_target_xcconfig = {
        'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'BOOMING_PLUGINGS_WARNING',
        'GCC_PREPROCESSOR_DEFINITIONS' => 'BOOMING_PLUGINGS_WARNING=1'
      }
    end
    
    xx.subspec 'Indicator' do |xxx|
      xxx.ios.source_files = 'Plugins/Indicator/*.swift'
      xxx.dependency 'Booming/Core'
      xxx.ios.pod_target_xcconfig = {
        'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'BOOMING_PLUGINGS_INDICATOR',
        'GCC_PREPROCESSOR_DEFINITIONS' => 'BOOMING_PLUGINGS_INDICATOR=1'
      }
    end
  end
  
end
