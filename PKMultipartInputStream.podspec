Pod::Spec.new do |spec|
  spec.name           = "PKMultipartInputStream"
  spec.version        = "1.1.0"
  spec.summary        = "An NSInputStream subclass suitable for building multipart/form-data HTTP requests bodies in MacOSX/iOS applications."
  spec.homepage       = "http://github.com/pyke369/PKMultipartInputStream"
  spec.license        = { :type => "MIT", :file => "LICENSE" }
  spec.author         = { "Pierre-Yves Kerembellec" => "py.kerembellec@gmail.com" }
  spec.preserve_paths = "README.*"
  spec.platform       = :ios
  spec.source         = { :git => "https://github.com/pyke369/PKMultipartInputStream.git", :tag => "1.1.0" }
  spec.source_files   = "PKMultipartInputStream.{h,m}"
  spec.requires_arc   = true
  spec.frameworks     = "MobileCoreServices"
end
