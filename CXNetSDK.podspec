#
# Be sure to run `pod lib lint CXNetworking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do | s |
    s.name             = 'CXNetSDK'
    s.version          = '1.0.1'
    s.summary          = 'HTTP网络库'
    
    # This description is used to generate tags and improve search results.
    # *Think: What does it do? Why did you write it? What is the focus?
    # *Try to keep it short, snappy and to the point.
    # *Write the description between the DESC delimiters below.
    # *Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = 'HTTP网络库，包括AFNetworking，YYModel等'
    
    s.homepage         = 'https://github.com/ishaolin/CXNetSDK'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'wshaolin' => 'ishaolin@163.com' }
    s.source           = { :git => 'https://github.com/ishaolin/CXNetSDK.git', :tag => s.version.to_s }

    s.ios.deployment_target = '9.0'
    
    s.public_header_files = 'CXNetSDK/Classes/**/*.h'
    s.source_files = 'CXNetSDK/Classes/**/*'
    
    s.resource_bundles = {
      'CXNetSDK' => ['CXNetSDK/Assets/**/*']
    }
    
    s.libraries = ['resolv', 'c++']
    
    s.dependency 'AFNetworking', '4.0.1'
    s.dependency 'YYModel', '1.0.4'
    s.dependency 'CXFoundation'
end
