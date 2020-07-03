echo "Clean old build"
find . -d -name "build" | xargs rm -rf
rm -rf build
rm -rf ios
rm -rf kwflutter_ios_result/ios_result

flutter packages get

cp -r .ios ios

flutter build ios --release --no-codesign

echo "-----------------------"
echo "-----------------------"

cd ios/Pods

echo "开始构建 debug for ios-simulator"

function lipoFw()
{
    echo "生成$1.framework..."
    xcodebuild build -configuration Debug ARCHS='x86_64' -target $1 BUILD_DIR=../../build/ios -sdk iphonesimulator -quiet
    
    iphonesimulator="../../build/ios/Debug-iphonesimulator/$1/$1.framework/$1"
    iphoneos="../../build/ios/Release-iphoneos/$1/$1.framework/$1"
    lipo -create "${iphonesimulator}" "${iphoneos}" -o "${iphoneos}"
}

for line in $(cat ../../.flutter-plugins)
do
    plugin_name=${line%%=*}
    lipoFw $plugin_name
done

lipoFw "FlutterPluginRegistrant"

echo "结束 debug for ios-simulator"

cd ..
cd ..

echo "-----------------------"
echo "-----------------------"
echo "开始 复制Flutter产物..."
mkdir kwflutter_ios_result/ios_result

#######分割线######
cp -r build/ios/Release-iphoneos/*/*.framework kwflutter_ios_result/ios_result
cp -r ios/Flutter/App.framework kwflutter_ios_result/ios_result
#注意注意:flutter 1.2版本后flutter_assets的位置变了, (直接build到app.framework里面了,不必手动处理它了)
#cp -r build/flutter_assets build_for_ios
cp -r ios/Flutter/engine/Flutter.framework kwflutter_ios_result/ios_result
cp -r ios/Flutter/FlutterPluginRegistrant/Classes/GeneratedPluginRegistrant.* kwflutter_ios_result/ios_result
rm -rf kwflutter_ios_result/ios_result/FlutterPluginRegistrant.framework
echo "完成 复制Flutter产物"

echo "开始 删除ios文件夹..."
rm -rf ios
echo "完成 删除ios文件夹"

echo "----结束----"




