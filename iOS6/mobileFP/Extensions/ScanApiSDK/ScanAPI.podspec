Pod::Spec.new do |s|
  s.name         = "ScanAPI"
  s.version      = "10.3.90"
  s.summary      = "Socket Mobile Wireless barcode scanners SDK."
  s.homepage     = "http://www.socketmobile.com"
  s.license      = { :type => "COMMERCIAL", :file => "LICENSE" }
  s.author       = { "Socket" => "developers@socketmobile.com" }
  s.documentation_url   = "http://www.socketmobile.com/docs/default-source/developer-documentation/scanapi.pdf?sfvrsn=2"
  s.platform     = :ios, "7.1"
  s.source 		= {:path => './' }
  s.ios.deployment_target = "7.1"
  s.source_files  = "**/*.{h,m,mm}"
  s.public_header_files = "*.h", "include/*"
  s.preserve_path = "**/*.a"
  s.resource = "*.wav"
  s.ios.vendored_library = "lib/libScanApiCore.a"
  s.ios.library = "c++"
  s.frameworks = "ExternalAccessory", "AudioToolbox", "AVFoundation"
end
