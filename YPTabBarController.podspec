#YPTabBarController.podspec
Pod::Spec.new do |s|
s.name         = "YPTabBarController"
s.version      = "2.0.6"
s.summary      = "A tab bar controller that can be highly customized, you can customize almost all elements, and it is easy to use."

s.homepage     = "https://github.com/yuping1989/YPTabBarController"
s.license      = 'MIT'
s.author       = { "Ping Yu" => "290180695@qq.com" }
s.platform     = :ios, "7.0"
s.ios.deployment_target = "7.0"
s.source       = { :git => "https://github.com/yuping1989/YPTabBarController.git", :tag => s.version}
s.source_files  = 'YPTabBarController/YPTabBarController/*.{h,m}'
s.requires_arc = true
end