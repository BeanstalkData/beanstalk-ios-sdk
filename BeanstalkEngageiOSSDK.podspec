Pod::Spec.new do |s|
  s.name             = 'BeanstalkEngageiOSSDK'
  s.version          = '0.5.29'
  s.summary          = 'Beanstalk Engage iOS SDK.'
  s.homepage         = 'https://github.com/BeanstalkData/beanstalk-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Beanstalk Data' => 'info@beanstalkdata.com' }
  s.source           = { :git => 'https://github.com/BeanstalkData/beanstalk-ios-sdk.git', :tag => s.version }

  s.ios.deployment_target = '8.0'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |cs|
    cs.dependency 'BeanstalkEngageiOSSDK/Model'
    cs.dependency 'BeanstalkEngageiOSSDK/Network'
    cs.dependency 'BeanstalkEngageiOSSDK/Control'
  end

  s.subspec 'Model' do |ms|
    ms.source_files   = 'BeanstalkEngageiOSSDK/Classes/Model/**/*'

    ms.dependency 'AlamofireObjectMapper', '~> 4.1.0'
  end

  s.subspec 'Network' do |ns|
    ns.source_files   = 'BeanstalkEngageiOSSDK/Classes/Network/**/*'

    ns.dependency 'BeanstalkEngageiOSSDK/Model'
    ns.dependency 'BeanstalkEngageiOSSDK/Vendor'

    ns.dependency 'Alamofire', '~> 4.4.0'
  end

  s.subspec 'Control' do |cns|
    cns.source_files   = 'BeanstalkEngageiOSSDK/Classes/Control/**/*'

    cns.dependency 'BeanstalkEngageiOSSDK/Model'
    cns.dependency 'BeanstalkEngageiOSSDK/Network'

    cns.dependency 'PKHUD', '~> 4.2.0'
    cns.dependency 'libPhoneNumber-iOS'
  end

  s.subspec 'Testing' do |ts|
    ts.source_files = 'BeanstalkEngageiOSSDK/Tests/**/*'

    ts.dependency 'BeanstalkEngageiOSSDK/Model'
    ts.dependency 'BeanstalkEngageiOSSDK/Network'
    ts.dependency 'BeanstalkEngageiOSSDK/Control'

    ts.dependency 'CCTestingUserDefaults'

    ts.framework = 'XCTest'
  end

  s.subspec 'Vendor' do |cns|
    cns.source_files   = 'BeanstalkEngageiOSSDK/Classes/Vendor/**/*'
  end

end
