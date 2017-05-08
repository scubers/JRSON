Pod::Spec.new do |s|
    # 基本信息
    s.name = 'JRSON' 
    s.version="1.0.9"
    s.summary = 'summary'
    s.homepage = 'http://www.jrwong.com'
    s.license = { :type => 'MIT', :file => 'LICENSE' }
    s.author = { 'author' => 'Jrwong' }
    s.ios.deployment_target = '8.0'

    s.source = { :git => 'https://github.com/scubers/JRSON.git', :tag => s.version }



    s.source_files = 'Classes/**/*.{h,m}'
    s.public_header_files = 'Classes/**/*.{h}'

 end
