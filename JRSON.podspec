Pod::Spec.new do |s|
    # 基本信息
    s.name = 'JRSON' 
    s.version="1.0.0"
    s.summary = 'summary'
    s.homepage = 'http://www.13322.com'
    s.license = { :type => 'MIT', :file => 'LICENSE' }
    s.author = { 'author' => 'HHLY' }
    s.ios.deployment_target = '8.0'

    # s.source = { :path => '.', :tag => s.version }
    s.source = { :git => 'git@192.168.10.44:wangjr/JRSON.git' }



    s.source_files = 'Classes/**/*.{h,m}'
    s.public_header_files = 'Classes/**/*.{h}'

    # s.resource_bundles = {
    #     'JRSON' => [
    #          "Classes/resource/*.lproj", 
    #          "Classes/resource/*.xcassets", 
    #          # "Classes/**/*.xib", # 有需要则添加自己的xib文件
    #     ]
    # }
    
    # s.dependency 'LYBase'
    
    # s.dependency 'MJExtension', :exclusive => true        # 类似这样添加自己的内部需要的pod, exclusive表示这个pod自己独有，如果大家都需要的pod，去LYCommon里面加入


 end
