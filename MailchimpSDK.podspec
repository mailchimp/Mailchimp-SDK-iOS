#
# Be sure to run `pod lib lint MailchimpSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MailchimpSDK'
  s.version          = '2.0.3'
  s.summary          = 'Mailchimp SDK for iOS'

  s.description      = <<-DESC
                       Add your mobile users to Mailchimp, apply tags, and track events.
                       DESC

  s.homepage         = 'https://mailchimp.com'
  s.social_media_url = 'https://twitter.com/mailchimp'
  s.license          = { :type => 'Custom', :file => 'LICENSE' }

  s.authors          = 'Mailchimp'

  s.platform         = :ios, '12.0'

  s.source           = { :git => 'https://github.com/mailchimp/Mailchimp-SDK-iOS.git', :tag => 'v' + s.version.to_s }
  s.source_files     = 'Sources/MailchimpSDK/MailchimpSDK/*.{swift,h,m}'

  s.vendored_frameworks = 'build/MailchimpSDK.xcframework'
end
