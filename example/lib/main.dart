import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_ali_cloud_auth/flutter_ali_cloud_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    FlutterAliCloudAuth.init();
  }

  Future<void> startAuth(String token, Function func) async {
    try {
      print(" call startAuth in main.dart");
      Map tokenResult = await FlutterAliCloudAuth.startAuth(token, func);
      print(tokenResult.toString());
    } catch (e) {
      print(e.toString());
      //setState(() {
      //  _tokenMsg = _tokenMsg + "\n" + e.message;
      //});
      if (e.code != "net_error" && e.code != "cancel") {
        return;
      }
    }
  }

  Future<void> startAuthWithConfig(Map config, Function func) async {
    try {
      print(" call startAuth in main.dart");
      Map tokenResult =
          await FlutterAliCloudAuth.startAuthWithConfig(config, func);
      print(tokenResult.toString());
    } catch (e) {
      print(e.toString());
      //setState(() {
      //  _tokenMsg = _tokenMsg + "\n" + e.message;
      //});
      if (e.code != "net_error" && e.code != "cancel") {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
              FlatButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  // side: BorderSide(
                  //   color: Colors.black12,
                  // ),
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: () {
                  startAuth("554b24700550468e90b6949f927cbd44",
                      (token, result, resultCode, resultMsg, callId) {
                    print("token!!" + token.toString());
                    print("result!!" + result.toString());
                    print("resultCode!!" + resultCode.toString());
                    print("resultMsg!!" + resultMsg.toString());
                    print("callId!!" + callId.toString());
                  });
                },
                child: Text("开始"),
              ),
              FlatButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  // side: BorderSide(
                  //   color: Colors.black12,
                  // ),
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: () {
                  startAuthWithConfig({
                    "skinInAssets": true,
                    "skinPath": "",
                    "token": "554b24700550468e90b6949f927cbd44",
                    "native": true
                  }, (token, result, resultCode, resultMsg, callId) {
                    print("token!!" + token.toString());
                    print("result!!" + result.toString());
                    print("resultCode!!" + resultCode.toString());
                    print("resultMsg!!" + resultMsg.toString());
                    print("callId!!" + callId.toString());
                  });
                },
                child: Text("开始22"),
              )
            ])),
      ),
    );
  }
}
