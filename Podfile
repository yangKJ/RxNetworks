use_frameworks!
inhibit_all_warnings!

#platform :ios, '10.0'

# 在Podfile上添加环境变量
# See: https://stackoverflow.com/questions/58795893/possibility-of-adding-environment-variables-on-podfile

ENV["RXNETWORKS_PLUGINGS_EXCLUDE"] = "INDICATOR"

target 'RxNetworks_Example' do
  
  pod 'RxCocoa'
  
#  pod 'RxNetworks/Core', :path => './'
#  pod 'RxNetworks/RxSwift', :path => './'
#  pod 'RxNetworks/HandyJSON', :path => './'
#  pod 'RxNetworks/Plugins/Cache', :path => './'
#  pod 'RxNetworks/Plugins/Loading', :path => './'
#  pod 'RxNetworks/Plugins/Indicator', :path => './'
  
  pod 'RxNetworks', :path => './'
  
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
