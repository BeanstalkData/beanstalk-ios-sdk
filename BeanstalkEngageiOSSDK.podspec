Pod::Spec.new do |s|
  s.name             = 'BeanstalkEngageiOSSDK'
  s.version          = '0.2.0'
  s.summary          = 'Beanstalk Engage iOS SDK.'
  s.homepage         = 'https://github.com/BeanstalkData/beanstalk-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Beanstalk Data' => 'info@beanstalkdata.com' }
  s.source           = { :git => 'https://github.com/BeanstalkData/beanstalk-ios-sdk.git', :tag => s.version }

  s.ios.deployment_target = '8.0'

  s.source_files = 'BeanstalkEngageiOSSDK/Classes/**/*'
  
  s.dependency 'Alamofire', '~> 3.5.1'
  s.dependency 'AlamofireObjectMapper', '~> 3.0.0'
  s.dependency 'PKHUD', '~> 3.2.1'
end
