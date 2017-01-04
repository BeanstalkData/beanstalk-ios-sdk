Pod::Spec.new do |s|
  s.name             = 'BeanstalkEngageiOSSDKTests'
  s.version          = '0.2.4'
  s.summary          = 'Beanstalk Engage iOS SDK Tests.'
  s.homepage         = 'https://github.com/BeanstalkData/beanstalk-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Beanstalk Data' => 'info@beanstalkdata.com' }
  s.source           = { :git => 'https://github.com/BeanstalkData/beanstalk-ios-sdk.git', :tag => s.version }

  s.ios.deployment_target = '8.0'

  s.source_files = 'BeanstalkEngageiOSSDK/Tests/**/*'

  s.framework = 'XCTest'
  s.dependency 'BeanstalkEngageiOSSDK'
end
