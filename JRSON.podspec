Pod::Spec.new do |s|
    # 基本信息
    s.name = 'JRSON' 
    s.version="1.0.0"
    s.summary = 'summary'
    s.homepage = 'http://www.13322.com'
    s.license = { :type => 'MIT', :file => 'LICENSE' }
    s.author = { 'author' => 'HHLY' }
    s.ios.deployment_target = '8.0'

    s.source = { :git => 'https://github.com/scubers/JRSON.git', :tag => s.version }



    s.source_files = 'Classes/**/*.{h,m}'
    s.public_header_files = 'Classes/**/*.{h}'


 end
