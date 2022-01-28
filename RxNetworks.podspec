#
# Be sure to run `pod lib lint RxNetworks.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RxNetworks'
  s.version          = '0.1.8'
  s.summary          = '🧚 响应式插件网络架构 RxSwift + Moya + HandyJSON + Plugins.'
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  s.homepage         = 'https://github.com/yangKJ/RxNetworks'
  s.description      = 'https://github.com/yangKJ/RxNetworks/blob/master/README.md'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yangkejun' => 'ykj310@126.com' }
  s.source           = { :git => 'https://github.com/yangKJ/RxNetworks.git', :tag => "#{s.version}" }
  s.social_media_url = 'https://juejin.cn/user/1987535102554472/posts'
  
  s.ios.deployment_target = '10.0'
  s.swift_version    = '5.0'
  s.requires_arc     = true
  s.static_framework = true
  s.module_name      = 'RxNetworks'
  s.ios.source_files = 'Sources/RxNetworks.h'
  
  s.pod_target_xcconfig = {
    'SWIFT_WHOLE_MODULE_OPTIMIZATION' => 'YES',
    "OTHER_SWIFT_FLAGS[config=Debug]" => "-D DEBUG",
  }
  
  s.subspec 'MoyaNetwork' do |xx|
    xx.source_files = 'Sources/MoyaNetwork/*.swift'
    xx.dependency 'RxSwift'
    xx.dependency 'Moya'
  end
  
  s.subspec 'HandyJSON' do |xx|
    xx.source_files = 'Sources/HandyJSON/*.swift'
    xx.dependency 'HandyJSON'
    xx.dependency 'RxSwift'
  end
  
  ################## -- 插件系列 -- ##################
  s.subspec 'MoyaPlugins' do |xx|
    xx.subspec 'Indicator' do |xxx|
      xxx.source_files = 'Sources/MoyaPlugins/Indicator/*.swift'
      xxx.dependency 'RxNetworks/MoyaNetwork'
      xxx.pod_target_xcconfig = {
        'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'RxNetworks_MoyaPlugins_Indicator',
        'GCC_PREPROCESSOR_DEFINITIONS' => 'RxNetworks_MoyaPlugins_Indicator=1'
      }
    end
    xx.subspec 'Debugging' do |xxx|
      xxx.source_files = 'Sources/MoyaPlugins/Debugging/*.swift'
      xxx.dependency 'RxNetworks/MoyaNetwork'
      xxx.pod_target_xcconfig = {
        'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'RxNetworks_MoyaPlugins_Debugging',
        'GCC_PREPROCESSOR_DEFINITIONS' => 'RxNetworks_MoyaPlugins_Debugging=1'
      }
    end
    xx.subspec 'Loading' do |xxx|
      xxx.source_files = 'Sources/MoyaPlugins/Loading/*.swift'
      xxx.dependency 'RxNetworks/MoyaNetwork'
      xxx.dependency 'MBProgressHUD'
    end
    xx.subspec 'Warning' do |xxx|
      xxx.source_files = 'Sources/MoyaPlugins/Warning/*.swift'
      xxx.dependency 'RxNetworks/MoyaNetwork'
      xxx.dependency 'Toast-Swift'
    end
    xx.subspec 'Cache' do |xxx|
      xxx.source_files = 'Sources/MoyaPlugins/Cache/*.swift'
      xxx.dependency 'RxNetworks/MoyaNetwork'
    end
    xx.subspec 'GZip' do |xxx|
      xxx.source_files = 'Sources/MoyaPlugins/GZip/*.swift'
      xxx.dependency 'RxNetworks/MoyaNetwork'
    end
  end
  
end
