import 'package:flutter/material.dart';
import 'package:kw_flutter/utils/KwUtil.dart';
import "moudle/KwLocation.dart";

class KwApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        theme: ThemeData(
          primaryColor: KwColors.primaryColor,
        ),
        debugShowCheckedModeBanner: false,
        home: KwRootPage());
  }
}

class KwRootPage extends StatefulWidget {
  @override
  _KwRootState createState() => _KwRootState();
}

class _KwRootState extends State<KwRootPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    KwUtils.screenInit(context);
    return Scaffold(body: KwLocation());
  }
}
