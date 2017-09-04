#
# Be sure to run `pod lib lint MappableObject.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MappableObject'
  s.version          = '0.2.1'
  s.summary          = 'A Realm extension that serializes arbitrary JSON into MappableObject class'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Arnoymous/MappableObject'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Arnoymous' => 'arnaud.dorgans@gmail.com' }
  s.source           = { :git => 'https://github.com/Arnoymous/MappableObject.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/arnauddorgans'

  s.watchos.deployment_target = '2.0'
  s.ios.deployment_target = '8.0'
#s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'MappableObject/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MappableObject' => ['MappableObject/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'RealmSwift', '~> 2.10.0'
  s.dependency 'ObjectMapper', '~> 2.2'

end
