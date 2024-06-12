#
# Be sure to run 'pod lib lint RxNetworks.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RxNetworks'
  s.version          = '1.1.0'
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
  
  s.subspec 'Core' do |xx|
    xx.dependency 'Booming/Core'
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
    xx.subspec 'AnimatedLoading' do |xxx|
      xxx.dependency 'NetworkLottiePlugin'
    end
    xx.subspec 'Cache' do |xxx|
      xxx.dependency 'NetworkCachePlugin'
    end
    xx.subspec 'Loading' do |xxx|
      xxx.dependency 'NetworkHudsPlugin'
    end
    xx.subspec 'Warning' do |xxx|
      xxx.dependency 'NetworkHudsPlugin'
    end
    xx.subspec 'Indicator' do |xxx|
      xxx.dependency 'Booming/Plugins'
    end
    xx.subspec 'Debugging' do |xxx|
      xxx.dependency 'Booming/Plugins'
    end
    xx.subspec 'GZip' do |xxx|
      xxx.dependency 'Booming/Plugins'
    end
    xx.subspec 'Shared' do |xxx|
      xxx.dependency 'Booming/Plugins'
    end
    xx.subspec 'Header' do |xxx|
      xxx.dependency 'Booming/Plugins'
    end
    xx.subspec 'Files' do |xxx|
      xxx.dependency 'Booming/Plugins'
    end
  end
  
end
