#
# Be sure to run `pod lib lint TCKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TCKit'
  s.version          = '0.1.0'
  s.summary          = 'simple JSON Request and JSON Response with TCKit.'

  s.homepage         = 'https://github.com/TTMarshelDaniel/TCKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'T T Marshel Daniel' => 'ttmdaniel@gmail.com' }
  s.source           = { :git => 'https://github.com/TTMarshelDaniel/TCKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'TCKit/Classes/**/*'
  
   s.resource_bundles = {
     'TCKit' => ['TCKit/Assets/*.png']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
