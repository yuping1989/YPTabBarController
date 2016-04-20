#YPTabBarController.podspec
Pod::Spec.new do |s|
s.name         = "YPTabBarController"
s.version      = "1.1.4"
s.summary      = "a tab bar controller."

s.homepage     = "https://github.com/yuping1989/YPTabBarController"
s.license      = 'MIT'
s.author       = { "Ping Yu" => "290180695@qq.com" }
s.platform     = :ios, "7.0"
s.ios.deployment_target = "7.0"
s.source       = { :git => "https://github.com/yuping1989/YPTabBarController.git", :tag => s.version}
s.source_files  = 'YPTabBarController/YPTabBarController/*.{h,m}'
s.requires_arc = true
end