import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kw_flutter/utils/KwUtil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class KwLocation extends StatefulWidget {
  @override
  _KwLocationState createState() => _KwLocationState();
}

class _KwLocationState extends State<KwLocation> {
  String longitude = '';
  String latitude = '';
  double topPadding;
  bool canCopy = false;
  static const methodChannel = const MethodChannel('com.kidswant.renke');

  @override
  void initState() {
    hasLocatePermission().then((v) {
      if (v) {
        startLocation(false);
      } else {
        showDeniedDialog();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          addLocationImage(),
          addLocationInfo(),
          addFooterBtn()
        ],
      ),
    );
  }

  Widget addLocationImage() {
    return Container(
      height: KwUtils.relative(433) + topPadding,
      width: KwUtils.screenWidth,
      padding: EdgeInsets.only(bottom: KwUtils.relative(75)),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Image.asset(
          'images/location_flutter.png',
          width: KwUtils.relative(216),
          height: KwUtils.relative(216),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget addLocationInfo() {
    return Container(
      height: KwUtils.relative(118),
      width: KwUtils.relative(520),
      padding: EdgeInsets.only(
          left: KwUtils.relative(32), right: KwUtils.relative(32)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: Color(0xFFF2F2F2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          addLocationInfoLeftWidget(),
          GestureDetector(
            onTap: getLocationInfoCopy,
            child: Container(
              height: KwUtils.relative(58),
              width: KwUtils.relative(145),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: Colors.white),
              child: Align(
                alignment: Alignment.center,
                child: Text("一键复制",
                    style: TextStyle(
                        color: canCopy ? Color(0xFFFF6EA2) : Colors.black26,
                        fontSize: KwUtils.fontSize(24))),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget addLocationInfoLeftWidget() {
    return Container(
        width: KwUtils.relative(280),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: KwUtils.relative(90),
                    child: Text(
                      '经度：',
                      style: TextStyle(
                          fontSize: KwUtils.fontSize(28),
                          color: Color(0xFF515151)),
                    ),
                  ),
                  Container(
                    width: KwUtils.relative(190),
                    child: Text(
                      KwUtils.safeString(longitude),
                      style: TextStyle(
                          fontSize: KwUtils.fontSize(28),
                          color: Color(0xFF8C8C8C)),
                    ),
                  )
                ],
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: KwUtils.relative(90),
                    child: Text(
                      '纬度：',
                      style: TextStyle(
                          fontSize: KwUtils.fontSize(28),
                          color: Color(0xFF515151)),
                    ),
                  ),
                  Container(
                    width: KwUtils.relative(160),
                    child: Text(
                      KwUtils.safeString(latitude),
                      style: TextStyle(
                          fontSize: KwUtils.fontSize(28),
                          color: Color(0xFF8C8C8C)),
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }

  Widget addFooterBtn() {
    double top = KwUtils.screenHeight -
        topPadding -
        KwUtils.relative(433) -
        KwUtils.relative(118) -
        KwUtils.relative(30) -
        (topPadding == 88 ? KwUtils.relative(98) : KwUtils.relative(60));

    return Container(
        height: KwUtils.relative(30),
        margin: EdgeInsets.only(top: top),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'images/location1_flutter.png',
              width: KwUtils.relative(20),
              height: KwUtils.relative(26),
              fit: BoxFit.fitHeight,
            ),
            Text(
              '  您所在位置的经纬度  ',
              style: TextStyle(
                  fontSize: KwUtils.fontSize(26), color: Color(0xFF999999)),
            ),
            GestureDetector(
              onTap: () {
                startLocation(true);
              },
              child: Container(
                height: KwUtils.relative(36),
                child: Row(
                  children: <Widget>[
                    Text(
                      '刷新',
                      style: TextStyle(
                          fontSize: KwUtils.fontSize(26),
                          color: Color(0xFFFF6EA2)),
                    ),
                    Image.asset(
                      'images/refresh_flutter.png',
                      width: KwUtils.relative(28),
                      height: KwUtils.relative(28),
                      fit: BoxFit.cover,
                    )
                  ],
                ),
              ),
            )
          ],
        ));
  }

  void getLocationInfoCopy() async {
    if (KwUtils.safeString(longitude).length == 0 &&
        KwUtils.safeString(latitude).length == 0) {
      return;
    }

    String copytext = "经度:" + longitude + ',纬度:' + latitude;
    KwUtils.showToast('复制成功');
    await Clipboard.setData(ClipboardData(text: copytext));
  }

  void startLocation(bool needtoast) async {
    setState(() {
      longitude = '';
      latitude = '';
    });

    var result;
    try {
      result = await methodChannel.invokeMethod('startLocation');
    } catch (e) {
      showDeniedDialog();
    }

    if (result['result'] == 'fail') {
      showDeniedDialog();
    } else {
      if (needtoast) {
        KwUtils.showToast('刷新成功');
      }
    }

    setState(() {
      longitude = KwUtils.safeString(result['longitude']);
      latitude = KwUtils.safeString(result['latitude']);
      canCopy = KwUtils.safeString(result['longitude']).length > 0;
    });
  }

  Future<bool> hasLocatePermission() async {
    var permissionStatus = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.location);
    return permissionStatus == PermissionStatus.granted;
  }

  void showDeniedDialog() {
    VoidCallback dialogClick = () {
      Navigator.pop(context, true);
      closeNativePage();
    };
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return LocatePermissionDeniedDialog(dialogClick);
        });
  }

  void closeNativePage() async {
    if (Platform.isIOS) {
      await methodChannel.invokeMethod('backToNative');
    } else if (Platform.isAndroid) {
      // FlutterBoost.singleton.close();
    }
  }
}

class LocatePermissionDeniedDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Duration insetAnimationDuration = const Duration(milliseconds: 100);
    Curve insetAnimationCurve = Curves.decelerate;

    RoundedRectangleBorder _defaultDialogShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2.0)));

    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: MediaQuery.removeViewInsets(
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        context: context,
        child: Center(
          child: Container(
            child: Material(
              elevation: 24.0,
              color: Theme.of(context).dialogBackgroundColor,
              type: MaterialType.card,
              //在这里修改成我们想要显示的widget就行了，外部的属性跟其他Dialog保持一致
              child: new Column(
                mainAxisSize: MainAxisSize.min,
//                crossAxisAlignment: CrossAxisAlignment.center,
//                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          dismissDialog(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: KwUtils.relative(22),
                              right: KwUtils.relative(22)),
                          child: Icon(
                            Icons.close,
                            color: Color(0xFFBFBFBF),
                            size: KwUtils.relative(44),
                          ),
                        ),
                      )),
                  Padding(
                    padding: EdgeInsets.only(top: KwUtils.relative(67)),
                    child: Image.asset(
                      'images/warning_flutter.png',
                      width: KwUtils.relative(117),
                      height: KwUtils.relative(117),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: KwUtils.relative(50),
                        bottom: KwUtils.relative(53)),
                    child: Text(
                      "定位权限未打开",
                      style: TextStyle(
                          color: Color(0xFF999999),
                          fontSize: KwUtils.fontSize(32)),
                    ),
                  ),
                  Container(
                    height: KwUtils.relative(1),
                    color: Color(0xFFE7E7E7),
                  ),
                  GestureDetector(
                    onTap: _dialogClick,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(
                          top: KwUtils.relative(25),
                          bottom: KwUtils.relative(25)),
                      child: Text(
                        "知道了",
                        style: TextStyle(
                            fontSize: KwUtils.fontSize(32),
                            color: Color(0xFFFF6EA2)),
                      ),
                    ),
                  ),
                ],
              ),
              shape: _defaultDialogShape,
            ),
          ),
        ),
      ),
    );
  }

  dismissDialog(context) {
    Navigator.pop(context, true);
  }

  final VoidCallback _dialogClick;

  LocatePermissionDeniedDialog(this._dialogClick);
}
