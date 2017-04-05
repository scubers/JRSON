Pod::Spec.new do |s|
    # 基本信息
    s.name = 'JRSON' 
    s.version="1.0.0"
    s.summary = 'summary'
    s.homepage = 'http://www.13322.com'
    s.license = { :type => 'MIT', :file => 'LICENSE' }
    s.author = { 'author' => 'HHLY' }
    s.ios.deployment_target = '8.0'

    s.source = { :git => 'git@192.168.10.44:wangjr/JRSON.git' }



    s.source_files = 'Classes/**/*.{h,m}'
    s.public_header_files = 'Classes/**/*.{h}'


 end
