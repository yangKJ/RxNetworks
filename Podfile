use_frameworks!
#inhibit_all_warnings!
#
#platform :ios, '10.0'

target 'RxNetworks_Example' do
  
  pod 'RxCocoa'
  
#  pod 'RxNetworks/HandyJSON', :path => './'
#  pod 'RxNetworks/MoyaNetwork', :path => './'
#  pod 'RxNetworks/MoyaPlugins/Cache', :path => './'
#  pod 'RxNetworks/MoyaPlugins/Loading', :path => './'
#  pod 'RxNetworks/MoyaPlugins/Indicator', :path => './'
  
  pod 'RxNetworks', :path => './'
  pod 'RxNetworks/HandyJSON', :path => './'
  pod 'RxNetworks/RxSwift', :path => './'
  pod 'RxNetworks/MoyaPlugins', :path => './'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 11.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      end
    end
  end
end
