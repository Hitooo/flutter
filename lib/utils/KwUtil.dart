import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class KwColors {
  static const Color primaryColor = Colors.blue; //通用主题色
  static const Color bgColor = Colors.black12; //通用背景色
  static const Color textBlack = Colors.black87; //一级标题的黑
  static const Color textDark = Colors.black54; //二级标题的黑
  static const Color textLight = Colors.black45; //三级标题的黑
}

class KwSizes {
  static final double fontBigger = KwUtils.fontSize(36); //超一级标题的大小
  static final double fontBig = KwUtils.fontSize(32); //一级标题的大小
  static final double fontMiddle = KwUtils.fontSize(28); //二级标题的大小
  static final double fontSmall = KwUtils.fontSize(24); //三级标题的大小
  static final double fontSmaller = KwUtils.fontSize(20); //四级标题或者标签内部的字体的大小
  static final double marginBig = KwUtils.relative(30); //一般用于控件与父视图之间的间距
  static final double marginSmall = KwUtils.relative(16); //控件与控件之间的间距
}

class KwUtils {
  //屏幕适配相关
  static const double _screenWidth = 750;
  static const double _screenHeight = 1334;

  static screenInit(context) {
    ScreenUtil.instance = ScreenUtil(width: _screenWidth, height: _screenHeight)
      ..init(context);
  }

  //日常布局，以宽度为主
  static relative(double width) {
    return ScreenUtil.getInstance().setWidth(width);
  }

  static double get screenWidth => KwUtils.relative(_screenWidth);
  static double get screenHeight => ScreenUtil.getInstance().setHeight(_screenHeight);

  static double fontSize(double size) {
    return ScreenUtil().setSp(size);
  }
  //结束

  //字符串相关
  static String safeString(String string) {
    return string == null ? '' : string;
  }
  //结束

  //toast
  static void showToast(String msg){

    if(msg == null){
      return;
    }

    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.black87,
      fontSize: KwUtils.fontSize(28),
      timeInSecForIos: 1,
      gravity: ToastGravity.CENTER,
      textColor: Colors.white
    );
  }
  //结束
}
