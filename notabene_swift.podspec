#
# Be sure to run `pod lib lint notabene_swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'notabene_swift'
  s.version          = '0.1.0'
  s.summary          = 'A Swift package for integrating the Notabene widget.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
NotaBeneSwift provides a clean API for integrating the Notabene widget into iOS applications.
It handles configuration, presentation, and communication with the widget.
                       DESC

  s.homepage         = 'https://github.com/Shafran123/notabene_swift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Shafran123' => 'mshafran13@gmail.com' }
  s.source           = { :git => 'https://github.com/Shafran123/notabene_swift', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '14.0'
  s.swift_version = '5.0'

  s.source_files = 'Classes/**/*.swift'
  
  s.resource_bundles = {
    'notabene_swift' => ['notabene_swift/Assets/*.png', 'Classes/**/*.xib']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'WebKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
