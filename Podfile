# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Globo News' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Globo News
    pod 'Kingfisher', '~> 5.0'
    pod 'FlagKit'
    pod "ViewAnimator"
    pod 'SwipeableTabBarController'
    pod 'EmptyDataSet-Swift', '~> 4.2.0'
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
               end
          end
   end
end
