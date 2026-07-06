Pod::Spec.new do |s|
  s.name             = 'MubeenDeviceSDK'
  s.version          = '2.0.0'
  s.summary          = 'iOS Device Intelligence SDK — device identity + fingerprint collection.'

  s.description      = <<-DESC
    Mubeen Device Intelligence SDK. Mints a persistent UUIDv7 device ID and
    submits a device fingerprint to the Mubeen backend for server-side analysis.
    Distributed as a closed-source, signed xcframework.
  DESC

  s.homepage         = 'https://github.com/mubeen-ai/MubeenIOSDeviceSDK'
  s.license          = { :type => 'Commercial', :text => 'Copyright 2026 Mubeen AI. All rights reserved.' }
  s.author           = { 'Mubeen' => 'engineering@mubeen.ai' }

  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'
  s.swift_version    = '5.10'

  # Binary distribution: host the zip from Scripts/build-xcframework.sh and set the URL.
  s.source           = {
    :http => 'https://github.com/mubeen-ai/Mubeen-IOS-SDK-public/releases/download/2.0.0/MubeenDeviceSDK.xcframework.zip'
  }
  s.vendored_frameworks = 'MubeenDeviceSDK.xcframework'

  s.frameworks       = 'Foundation', 'DeviceCheck', 'CryptoKit', 'Security', 'Network'
  s.ios.frameworks   = 'UIKit'
end
