Pod::Spec.new do |s|
  s.name             = 'BeanstalkEngageiOSSDK'
  s.version          = '0.7.5'
  s.summary          = 'Beanstalk Engage iOS SDK.'
  s.homepage         = 'https://github.com/BeanstalkData/beanstalk-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Beanstalk Data' => 'info@beanstalkdata.com' }
  s.source           = { :git => 'https://github.com/BeanstalkData/beanstalk-ios-sdk.git', :tag => s.version }

  s.ios.deployment_target = '8.3'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |cs|
    cs.dependency 'BeanstalkEngageiOSSDK/Common'
    cs.dependency 'BeanstalkEngageiOSSDK/Model'
    cs.dependency 'BeanstalkEngageiOSSDK/Network'
    cs.dependency 'BeanstalkEngageiOSSDK/Control'
    cs.dependency 'PromiseKit/CorePromise', '~> 6.3'
  end

  s.subspec 'Model' do |ms|
    ms.source_files   = 'BeanstalkEngageiOSSDK/Classes/Model/**/*'

    ms.dependency 'AlamofireObjectMapper', '~> 5.0.0'
  end

  s.subspec 'Network' do |ns|
    ns.source_files   = 'BeanstalkEngageiOSSDK/Classes/Network/**/*'
    ns.resource_bundles = { 'BeanstalkEngageiOSSDK' => ['BeanstalkEngageiOSSDK/Certificates/*.cer'] }
    
    ns.dependency 'BeanstalkEngageiOSSDK/Common'
    ns.dependency 'BeanstalkEngageiOSSDK/Model'
    ns.dependency 'BeanstalkEngageiOSSDK/Vendor'

    ns.dependency 'Alamofire', '~> 4.6.0'
    ns.dependency 'ReachabilitySwift', '~> 4.1.0'
  end

  s.subspec 'Control' do |cns|
    cns.source_files   = 'BeanstalkEngageiOSSDK/Classes/Control/**/*'

    cns.dependency 'BeanstalkEngageiOSSDK/Common'
    cns.dependency 'BeanstalkEngageiOSSDK/Model'
    cns.dependency 'BeanstalkEngageiOSSDK/Network'
  end

  s.subspec 'Testing' do |ts|
    ts.source_files = 'BeanstalkEngageiOSSDK/Tests/**/*'

    ts.dependency 'BeanstalkEngageiOSSDK/Common'
    ts.dependency 'BeanstalkEngageiOSSDK/Model'
    ts.dependency 'BeanstalkEngageiOSSDK/Network'
    ts.dependency 'BeanstalkEngageiOSSDK/Control'

    ts.dependency 'CCTestingUserDefaults'

    ts.framework = 'XCTest'
  end

  s.subspec 'Common' do |cms|
    cms.source_files   = 'BeanstalkEngageiOSSDK/Classes/Common/**/*'

    cms.dependency 'BeanstalkEngageiOSSDK/Localization'
    cms.dependency 'BeanstalkEngageiOSSDK/Vendor'
    cms.dependency 'BeanstalkEngageiOSSDK/Network'
    cms.dependency 'Alamofire', '~> 4.6.0'
    cms.dependency 'libPhoneNumber-iOS'
  end

  s.subspec 'Localization' do |l|
    l.resources      = 'BeanstalkEngageiOSSDK/Localizables/*.lproj'
    l.preserve_paths = 'BeanstalkEngageiOSSDK/Localizables/*.lproj'
    l.source_files   = 'BeanstalkEngageiOSSDK/Classes/Localizables/**/*'
  end

  s.subspec 'Vendor' do |vs|
    vs.source_files   = 'BeanstalkEngageiOSSDK/Classes/Vendor/**/*'
  end

end
