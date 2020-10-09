use_frameworks!
platform :ios, '11.0'
workspace 'taxi'
def common_pods
  
  # Conjunto de utilidades do Firebase
  pod 'Firebase/Core', '~> 6.29.0'
  pod 'FirebaseUI/Phone', '~> 8.0'
  pod 'Firebase/Messaging', '~> 6.29.0'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  
  # Formulários
  pod 'Eureka', '~> 5.3.1'
  pod 'ImageRow', '~> 4.0.0'
  
  # Componente de chat
  pod 'MessageKit', '~> 3.1.0'
  
  # Componente para alertas personalizados
  pod 'StatusAlert', '~> 1.1.1'
  
  # Carregamento de imagem via web http
  pod 'Kingfisher', '~> 5.14.1'
  
  # Conexão via socket
  pod 'Socket.IO-Client-Swift', '~> 15.2.0'
  
  # Animações
  pod 'lottie-ios', '~> 3.1.8'
  
  # Wrapper para atributos de String
  pod 'SwiftyAttributes', '~> 5.1.1'
  
  # Componente de pullup
  pod 'PullUpController', '~> 0.8.0'
  
  # Componente de review com estrelas
  pod 'Cosmos', '~> 22.1.0'
  
  # Busca de endereços do Google
  pod 'GooglePlaces', '~> 3.9.0'
  
  # Toast view feedback
  pod 'Toast-Swift', '~> 5.0.1'
  
  # Gerenciador de conexão
  pod 'ReachabilitySwift', '~> 5.0.0'
end

target 'rider' do
  project 'rider/rider.xcodeproj'
  common_pods
  
  # Rolagem para Labels
  pod 'MarqueeLabel/Swift', '~> 3.2.1'
end

target 'driver' do
  project 'driver/driver.xcodeproj'
  common_pods
  # Componente de carrosel
  pod 'iCarousel', '~> 1.8.3'
  
  # Componente de gráficos
  pod 'Charts', '~> 3.5.0'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    
    if config.name == 'Debug'
      
      puts "Found config #{config.name}"
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    end
  end
end


