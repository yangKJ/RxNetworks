# Uncomment the next line to define a global platform for your project

source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git' # 清华镜像源
#source 'https://github.com/CocoaPods/Specs.git'
#source 'git@github.com:Condy/PrivatePod.git' # 私有索引

use_frameworks!
inhibit_all_warnings!

platform :ios, '11.0'

# 在Podfile上添加环境变量
# See: https://stackoverflow.com/questions/58795893/possibility-of-adding-environment-variables-on-podfile

ENV["RXNETWORKS_PLUGINGS_EXCLUDE"] = "INDICATOR"

target 'RxNetworks_Example' do
  
  pod 'RxCocoa'
  pod 'HollowCodable'
  
  pod 'RxNetworks', :path => './'
  pod 'Booming', :path => './'
  pod 'NetworkCachePlugin', :path => './'
  pod 'NetworkLottiePlugin', :path => './'
  pod 'NetworkHudsPlugin', :path => './'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 10.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
      end
    end
  end
end
