# flutter
flutter
以下描述统一说法：iOS原生的工程，叫主工程；生成Flutter工程之后，Flutter工程里面也会包含一个iOS工程，这个工程叫壳工程

0、Flutter的安装自行百度

1、创建Flutter工程
打开命令行，cd到主工程的平级目录  
运行“flutter create -t module your_flutter”,执行完之后，主工程的平级目录下会多一个your_flutter工程  
进入your_flutter文件夹，会有.ios文件夹，这个文件夹就是壳工程（your_flutter/.iOS），打开壳工程把BundleID以及Team设置成和主工程一样的（好像不需要设置，但是被折腾怕了，最好稳重一点），Bitcode设置成NO，同时Workspace Setting中的BuildSystem设置成Legacy  
继续进入Flutter文件夹（your_flutter/.ios/Flutter），这里面包含里所有的Flutter产物，同时会有一个podhelper.rb,这个rb文件的作用就是把所有的产物pod到主工程；  
此时可以正常用Dart代码开发Flutter页面了  
注意：如果你的Flutter工程是用VSCode生成的，就没有这个podhelper.rb，同时壳工程的名字叫ios，没有”.”,这个会影响很多Flutter命令的执行，所以建议用命令行生成Flutter工程 
 

2、主工程的配置

打开podfile，在尾部添加如下代码，因为Flutter目前不支持BITCODE  
post_install do |installer| 
    installer.pods_project.targets.each do |pod_target| 
        pod_target.build_configurations.each do |config| 
            config.build_settings['ENABLE_BITCODE'] = 'NO' 
        end 
    end 
end 
然后在“target 'XXXX' do”上面添加如下代码，kwflutter_iosresult这个库后面会讲到  
#Flutter集成方式：0表示直接集成，无需Flutter环境，1表示Flutter开发 
IsFlutterSourceCode = 1 

def FlutterModulePod 

    if IsFlutterSourceCode == 1 
        flutter_application_path = '../your_flutter/'; 
        load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb’) 
        install_all_flutter_pods(flutter_application_path) 
    else 
        pod 'kwflutter_iosresult', :git => 'https://code.haiziwang.com/19162192/kwflutter_ios_result.git', :branch => 'master' 
    end 
end 
然后在“target 'XXXX' do”下面添加如下代码，调用一下  
FlutterModulePod() 
效果如下：  
 
然后在AppDelegate中把父类替换成FlutterAppDelegate；如果你想引用FlutterBoost，那么百度一下FlutterBoost的集成即可  
此时可以编写原生的FlutterViewController容器了，关于原生与Flutter如何通信，需要自己去上网查看  

3、Flutter产物的仓库创建
建立git仓库，例如我上面提到的名字：kwflutter_ios_result 
新建podspec文件，参考内容如下：  
Pod::Spec.new do |s| 
  s.name             = 'kwflutter_iosresult' 
  s.version          = '1.0' 
  s.summary          = 'Flutter产物' 
  s.description      = <<-DESC 
  Flutter产物. 
                       DESC 
  s.homepage         = 'https://code.haiziwang.com/19162192/kwflutter_ios_result' 
  s.license      = { :type => 'MIT', :file => 'LICENSE'} 
  s.author           = { 'hitoo' => 'haitao.zhang@haiziwang.com'} 
  s.source           = { :git => 'https://code.haiziwang.com/19162192/kwflutter_ios_result.git'} 


  s.pod_target_xcconfig = { 
    'ENABLE_BITCODE' =>  'false' 
  } 


  s.vendored_frameworks = "ios_result/**/*.framework" 
  s.source_files = 'RKFlutterVC.{h.m}',"ios_result/**/GeneratedPluginRegistrant.{h.m}" 
  s.requires_arc = true 
end 
然后把仓库Checkout到本地，我是直接把仓库放在了Flutter工程目录下面了，文件夹名字叫kwflutter_ios_result，然后在gitignore文件中忽略这个文件夹  
这样做的好处是后续用脚本生成Flutter产物的时候，自动把产物生成在kwflutter_ios_result目录下面，这样就省事很多，后面需要提交的时候直接提交git即可  

4、Flutter产物的生成
当IsFlutterSourceCode = 1，在主工程中执行Pod install并且编译运行，虽然也可以生成Flutter产物，但是这个产物目前来讲是残缺的，也许是我配置的原因；Flutter中引用的第三方插件，有的会有对应的原生库，这些库都存在于本地安装的Flutter环境中，直接编译运行的话，并不会把第三方插件打包成Framework导入到工程中，而是直接引用了本地安装的Flutter环境中库。这样如果提交到Git仓库，在没有Flutter环境的电脑中（别人的电脑或者打包机器）会编译报错。  
 
新建编译Flutter产物的脚本文件，名字随便起，例如：buildforios.sh，放在Flutter工程根目录下，参考内容如下：  
其中的kwflutter_ios_result需要替换成你们自己的  
echo "Clean old build" 
find . -d -name "build" | xargs rm -rf 
rm -rf build 
rm -rf kwflutter_ios_result/ios_result 

echo "开始获取 packages 插件资源" 
flutter packages get 

echo "开始Copy.ios文件到ios" 
cp -r .ios ios 
echo "Copy.ios文件到ios 已完成" 

echo "开始构建 release for ios" 
flutter build ios --release --no-codesign 
echo "构建 release 已完成" 

echo "开始 处理framework和资源文件" 
mkdir kwflutter_ios_result/ios_result 

#######分割线###### 
cp -r build/ios/Release-iphoneos/*/*.framework kwflutter_ios_result/ios_result 
#cp -r build/ios/Release-iphoneos/*/*.a build_for_ios 
cp -r ios/Flutter/App.framework kwflutter_ios_result/ios_result 
#注意注意:flutter 1.2版本后flutter_assets的位置变了, (直接build到app.framework里面了,不必手动处理它了) 
#cp -r build/flutter_assets build_for_ios 
cp -r ios/Flutter/engine/Flutter.framework kwflutter_ios_result/ios_result 
cp -r ios/Flutter/FlutterPluginRegistrant/Classes/GeneratedPluginRegistrant.* kwflutter_ios_result/ios_result 
rm -rf kwflutter_ios_result/ios_result/FlutterPluginRegistrant.framework 
echo "处理framework和资源文件 已完成" 

echo "删除ios文件夹" 
rm -rf ios 
echo "删除ios文件夹 已完成" 

echo "----结束----" 
打开命令行，cd到Flutter工程的根目录，执行上面的脚本文件  
bash buildforios.sh 
执行完之后，在Flutter工程的根目录下，找到第3步中你checkout到本地的产物仓库，里面会多一个ios_result文件夹，这里面就是Flutter的完整的产物了，所有的第三方库都是以Framework的形式存在  
注意：如果Cocoapods版本低，会出现无法生成Framework的情况（生成的是.a），建议升级Pod版本；  
注意：如果你用高版本的Xcode生成的Framework，会出现在低版本的Xcode上无法运行的情况，原因是第三方库中使用 @available来判断了系统版本，因为高版本Xcode的 @available 实现中使用了新的 api  
Undefined symbols for architecture arm64或者Undefined symbols for architecture arm7或者Undefined symbol: ___isPlatformVersionAtLeast 

5、Flutter产物的集成
提交第4步中生成的Flutter产物到远程仓库  
打开主工程的Podfile，替换kwflutter_iosresult这个Pod库的地址，把IsFlutterSourceCode改为0，然后pod install  
结束  

6、场景问题汇总
第三方库无法生成framework（请按提示升级Pod版本） 
Undefined symbols for architecture arm64（高版本Xcode打包的framework无法在低版本Xcode运行，请下载低版本Xcode，目前打包机器是低版本） 
Undefined symbols for architecture x86_64（编译生成的产物，不支持在模拟器上运行） 
