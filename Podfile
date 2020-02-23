# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

use_frameworks!

def base_pods
	pod 'PromiseKit'
end

target 'pulse.eco' do
	base_pods

	pod 'GoogleMaps'
	pod 'Charts'
	pod 'lottie-ios', ' 2.5.3'
	pod 'Firebase/Core'
end

target 'widget' do 
	base_pods
end

target 'tests' do 
	base_pods
	pod 'Firebase/Core'
end
