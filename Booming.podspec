#
# Be sure to run 'pod lib lint Booming.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Booming'
  s.version          = '1.0.8'
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
    xx.subspec 'Features' do |xxx|
      xxx.source_files = 'Plugins/Features/*.swift'
      xxx.dependency 'Booming/Core'
      xxx.pod_target_xcconfig = {
        'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'BOOMING_PLUGINGS_FEATURES',
        'GCC_PREPROCESSOR_DEFINITIONS' => 'BOOMING_PLUGINGS_FEATURES=1'
      }
    end
    
    ################## -- ios插件系列 -- ##################
    xx.subspec 'Views' do |xxx|
      xxx.ios.source_files = 'Plugins/Views/*.swift'
      xxx.dependency 'Booming/Core'
      xxx.ios.pod_target_xcconfig = {
        'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'BOOMING_PLUGINGS_VIEWS',
        'GCC_PREPROCESSOR_DEFINITIONS' => 'BOOMING_PLUGINGS_VIEWS=1'
      }
    end
    
    xx.subspec 'Huds' do |xxx|
      xxx.ios.source_files = 'Plugins/Huds/*.swift'
      xxx.dependency 'Booming/Core'
      xxx.ios.dependency 'MBProgressHUD'
    end
  end
  
end
