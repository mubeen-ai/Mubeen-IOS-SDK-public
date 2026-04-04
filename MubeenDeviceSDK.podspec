Pod::Spec.new do |s|
  s.name             = 'MubeenDeviceSDK'
  s.version          = '1.0.0'
  s.summary          = 'iOS Device Intelligence SDK for fraud prevention and risk evaluation.'

  s.description      = <<-DESC
    Mubeen Device Intelligence SDK collects device fingerprint signals and submits
    them to the Mubeen backend for real-time risk evaluation. Used in mobile payments
    and account security flows.
  DESC

  s.homepage         = 'https://github.com/mubeen-ai/MubeenDeviceSDK'
  s.license          = { :type => 'Commercial', :text => 'Copyright Mubeen AI. All rights reserved.' }
  s.author           = { 'Mubeen' => 'engineering@mubeen.ai' }
  s.source           = { :http => 'https://github.com/mubeen-ai/MubeenDeviceSDK/releases/download/1.0.0/MubeenDeviceSDK.xcframework.zip' }

  s.ios.deployment_target = '15.0'
  s.swift_version    = '5.10'

  s.vendored_frameworks = 'MubeenDeviceSDK.xcframework'

  s.frameworks       = 'Foundation', 'UIKit', 'DeviceCheck', 'CryptoKit', 'Security', 'Network'
end
