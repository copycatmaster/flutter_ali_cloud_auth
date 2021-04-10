
import 'dart:async';

import 'package:flutter/services.dart';


class FlutterAliCloudAuth {
  static var AUDIT_PASS = 1;
  static var AUDIT_FAIL = 0;
  static var AUDIT_NOT = -1;

  static Map<int,String> code_msg = {
    1:"认证通过",
    -1:"未完成认证，原因：用户在认证过程中，主动退出。",
    -10:"未完成认证，原因：设备问题，如设备无摄像头、无摄像头权限、摄像头初始化失败、当前手机不支持端活体算法等。",
   -20:"未完成认证，原因：端活体算法异常，如算法初始化失败、算法检测失败等。",
    -30:"未完成认证，原因：网络问题导致的异常，如网络链接错误、网络请求失败等。需要您检查网络并关闭代理。",
    -40:"未完成认证，原因：SDK异常，原因包括SDK初始化失败、SDK调用参数为空、活体检测被中断（如电话打断）等。",
    -50:"未完成认证，原因：用户活体失败次数超过限制。",
    -60:"未完成认证，原因：手机的本地时间和网络时间不同步。",
    -10000:"未完成认证，原因：客户端发生未知错误。",
    3001:"未完成认证，原因：认证token无效或已过期。",
    3101:"未完成认证，原因：用户姓名身份证实名校验不匹配。",
    3102:"未完成认证，原因：实名校验身份证号不存在。",
    3103:"未完成认证，原因：实名校验身份证号不合法。",
    3104:"未完成认证，原因：认证已通过，重复提交。",
    3203:"未完成认证，原因：设备不支持刷脸。",
    3204:"未完成认证，原因：非本人操作。",
    3206:"未完成认证，原因：非本人操作。"
  };

  static const MethodChannel _channel = const MethodChannel('flutter_ali_cloud_auth');
  static int idPool = 1;
  static Map<int, Function> callbacks = {};
  static Future<bool> init() async {
    Future<Map> _methodCallHandler(MethodCall call) async {
      print("_methodCallHandler call");
      print(call.toString());
      if (call.method == "RPVerifyFinish") {
        int callId = call.arguments['callId'];
        String token = call.arguments['token'];
        int result = call.arguments['result'];
        String resultCode = call.arguments['resultCode'];
        String resultMsg = call.arguments['resultMsg'];
        if (callbacks[callId] != null) {
          callbacks[callId](token, result, resultCode, resultMsg, callId);
          Map ret = {};
          ret['code'] = "ok";
          return ret;
        } else {
          print("error! bad callId" + callId.toString());
        }
      } else if (call.method == "test") {
        print('call test!!!test!!!');
        Map ret = {};
        ret['code'] = '22';
        ret['data'] = {"msg": "good"};
        return ret;
      } else {
        Map ret = {};
        ret['code'] = 'no_method';
        ret['msg'] = "no this method";
        ret['data'] = {"msg": "good"};
        return ret;
      }
    }

    _channel.setMethodCallHandler(_methodCallHandler);
    return true;
  }

  static Future<Map> startAuth(String token, Function resultCallback) async {
    idPool += 1;
    callbacks[idPool] = resultCallback;
    print("call _channel startAuth");
    final Map ret = await _channel
        .invokeMethod('startAuth', {"token": token, "callId": idPool});
    ret['callId'] = idPool;
    return ret;
  }
  static Future<Map> startAuthNative(String token, Function resultCallback) async {
    idPool += 1;
    callbacks[idPool] = resultCallback;
    print("call _channel startAuthNative");
    final Map ret = await _channel
        .invokeMethod('startAuthNative', {"token": token, "callId": idPool});
    ret['callId'] = idPool;
    return ret;
  }
}

