use_frameworks!
platform :ios, '11.0'
workspace 'taxi'
def common_pods
  pod 'Firebase/Core'
  pod 'FirebaseUI/Phone'
  pod 'Firebase/Analytics'
  pod 'Firebase/Messaging'
  pod 'Eureka'
  #pod 'Eureka', :git => 'https://github.com/xmartlabs/Eureka.git', :branch => 'xcode12'
  pod 'ImageRow'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'BraintreeDropIn'
  pod 'Stripe'
  pod 'MessageKit'
  pod 'StatusAlert'
  pod 'Kingfisher'
  pod 'Socket.IO-Client-Swift'
  pod 'lottie-ios'
end

target 'rider' do
  project 'rider/rider.xcodeproj'
  common_pods
  pod 'MarqueeLabel/Swift'
end

target 'driver' do
  project 'driver/driver.xcodeproj'
  common_pods
  pod 'iCarousel'
  pod 'Charts'
end


