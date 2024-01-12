#
# Be sure to run 'pod lib lint RxNetworks.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RxNetworks'
  s.version          = '0.4.9'
  s.summary          = 'Network Architecture API RxSwift + Moya + HandyJSON + Plugins.'
  
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
  
  s.ios.deployment_target = '11.0'
  s.swift_version    = '5.0'
  s.requires_arc     = true
  s.static_framework = true
  s.module_name      = 'RxNetworks'
  s.ios.source_files = 'Sources/RxNetworks.h'
  #s.default_subspec  = "Core"
  
  s.pod_target_xcconfig = {
    'SWIFT_WHOLE_MODULE_OPTIMIZATION' => 'YES',
    "OTHER_SWIFT_FLAGS[config=Debug]" => "-D DEBUG",
  }
  
  s.subspec 'Core' do |xx|
    xx.source_files = 'Sources/Core/*.swift'
    xx.dependency 'Moya'
  end
  
  s.subspec 'RxSwift' do |xx|
    xx.source_files = 'Sources/RxSwift/*.swift'
    xx.dependency 'RxSwift'
    xx.dependency 'RxNetworks/Core'
  end
  
  s.subspec 'HandyJSON' do |xx|
    xx.source_files = 'Sources/HandyJSON/*.swift'
    xx.dependency 'HandyJSON'
  end
  
  ################## -- 插件系列 -- ##################
  s.subspec 'Plugins' do |xx|
    xx.subspec 'Indicator' do |xxx|
      xxx.source_files = 'Sources/Plugins/Indicator/*.swift'
      xxx.dependency 'RxNetworks/Core'
      xxx.pod_target_xcconfig = {
        'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'RXNETWORKS_PLUGINGS_INDICATOR',
        'GCC_PREPROCESSOR_DEFINITIONS' => 'RXNETWORKS_PLUGINGS_INDICATOR=1'
      }
    end
    xx.subspec 'Debugging' do |xxx|
      xxx.source_files = 'Sources/Plugins/Debugging/*.swift'
      xxx.dependency 'RxNetworks/Core'
      xxx.pod_target_xcconfig = {
        'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'RXNETWORKS_PLUGINGS_DEBUGGING',
        'GCC_PREPROCESSOR_DEFINITIONS' => 'RXNETWORKS_PLUGINGS_DEBUGGING=1'
      }
    end
    xx.subspec 'Loading' do |xxx|
      xxx.source_files = 'Sources/Plugins/Loading/*.swift'
      xxx.dependency 'RxNetworks/Core'
      xxx.ios.dependency 'MBProgressHUD'
    end
    xx.subspec 'AnimatedLoading' do |xxx|
      xxx.source_files = 'Sources/Plugins/AnimatedLoading/*.swift'
      xxx.dependency 'RxNetworks/Core'
      xxx.dependency 'lottie-ios'#, '~> 4.2.0'
    end
    xx.subspec 'Warning' do |xxx|
      xxx.source_files = 'Sources/Plugins/Warning/*.swift'
      xxx.dependency 'RxNetworks/Core'
      xxx.ios.dependency 'MBProgressHUD'
      xxx.pod_target_xcconfig = {
        'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'RXNETWORKS_PLUGINGS_WARNING',
        'GCC_PREPROCESSOR_DEFINITIONS' => 'RXNETWORKS_PLUGINGS_WARNING=1'
      }
    end
    xx.subspec 'Cache' do |xxx|
      xxx.source_files = 'Sources/Plugins/Cache/*.swift'
      xxx.dependency 'RxNetworks/Core'
      xxx.dependency 'CacheX'
    end
    xx.subspec 'GZip' do |xxx|
      xxx.source_files = 'Sources/Plugins/GZip/*.swift'
      xxx.dependency 'RxNetworks/Core'
    end
    xx.subspec 'Shared' do |xxx|
      xxx.source_files = 'Sources/Plugins/Shared/*.swift'
      xxx.dependency 'RxNetworks/Core'
      xxx.pod_target_xcconfig = {
        'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'RXNETWORKS_PLUGINGS_SHARED',
        'GCC_PREPROCESSOR_DEFINITIONS' => 'RXNETWORKS_PLUGINGS_SHARED=1'
      }
    end
    xx.subspec 'Header' do |xxx|
      xxx.source_files = 'Sources/Plugins/Header/*.swift'
      xxx.dependency 'RxNetworks/Core'
      xxx.pod_target_xcconfig = {
        'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'RXNETWORKS_PLUGINGS_HTTPHEADER',
        'GCC_PREPROCESSOR_DEFINITIONS' => 'RXNETWORKS_PLUGINGS_HTTPHEADER=1'
      }
    end
    xx.subspec 'Files' do |xxx|
      xxx.source_files = 'Sources/Plugins/Files/*.swift'
      xxx.dependency 'RxNetworks/Core'
      xxx.pod_target_xcconfig = {
        'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'RXNETWORKS_PLUGINGS_DOWNLOAD_UPLOAD',
        'GCC_PREPROCESSOR_DEFINITIONS' => 'RXNETWORKS_PLUGINGS_DOWNLOAD_UPLOAD=1'
      }
    end
  end
  
end
