package com.bee.flutter_ali_cloud_auth;


import java.util.HashMap;
import androidx.annotation.NonNull;
import android.util.Log;
import android.app.Activity;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;


import com.alibaba.security.realidentity.RPEventListener;
import com.alibaba.security.realidentity.RPResult;
import com.alibaba.security.realidentity.RPVerify;
import com.alibaba.security.realidentity.RPConfig;



/** FlutterAliCloudAuthPlugin */
public class FlutterAliCloudAuthPlugin implements FlutterPlugin, MethodCallHandler,ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private Activity activity;

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        //Log.e("flutter"," onAttachedToActivity !!!");
        activity = binding.getActivity();



    }

    public static HashMap<String,Object> packResult(final String code,final  String msg,final  HashMap<String,Object> data) {
        return new HashMap<String,Object>(){{
            put("code",code);
            put("msg",msg);
            put("data",data);
        }};
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        //Log.e("flutter"," onDetachedFromActivityForConfigChanges !!!");
        activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        //Log.e("flutter"," onReattachedToActivityForConfigChanges !!!");
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        //Log.e("flutter"," onDetachedFromActivity !!!");
        activity = null;
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        //Log.e("flutter"," onAttachedToEngine !!!");
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_ali_cloud_auth");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        Log.i("flutter","onMethodCall:"+call.method);
        if(call.argument("token")!=null) {
            Log.i("flutter","token:"+call.argument("token").toString());
        }
        if(call.argument("callId")!=null) {
            Log.i("flutter","callId:"+call.argument("callId").toString());
        }
        if(call.argument("native")!=null) {
            Log.i("flutter","native:"+call.argument("native").toString());
        }
        if(call.argument("skinInAssets")!=null) {
            Log.i("flutter","skinInAssets:"+call.argument("skinInAssets").toString());
        }
        if(call.argument("skinPath")!=null) {
            Log.i("flutter","skinPath:"+call.argument("skinPath").toString());
        }

        if (call.method.equals("startAuthWithConfig")) {
            final String token = call.argument("token");
            final Integer callId = call.argument("callId");
            final Boolean isNative = call.argument("native");
            final Boolean skinInAssets = call.argument("skinInAssets");
            final String skinPath = call.argument("skinPath");
            if(activity == null) {
                result.success(packResult("fail", "fail", new HashMap<String,Object>(){{
                }}));
            }
            //Log.e("flutter","call RPVerify.startByNative now!!!");
            RPEventListener listener = new RPEventListener() {
                @Override
                public void onFinish(RPResult auditResult,String code,String msg) {
                    int resultCode = 0;
                    if (auditResult == RPResult.AUDIT_PASS) {
                        // 认证通过。建议接入方调用实人认证服务端接口DescribeVerifyResult来获取最终的认证状态，并以此为准进行业务上的判断和处理。
                        // do something
                        resultCode = 1;
                    } else if (auditResult == RPResult.AUDIT_FAIL) {
                        // 认证不通过。建议接入方调用实人认证服务端接口DescribeVerifyResult来获取最终的认证状态，并以此为准进行业务上的判断和处理。
                        // do something
                        resultCode = -1;
                    } else if (auditResult == RPResult.AUDIT_NOT) {
                        // 未认证，具体原因可通过code来区分（code取值参见错误码说明），通常是用户主动退出或者姓名身份证号实名校验不匹配等原因，导致未完成认证流程。
                        // do something
                        resultCode = 0;
                    }
                    final int resultTemp = resultCode;
                    final String resultCodeTemp = code;
                    final String resultMsgTemp = msg;
                    Log.e("flutter","onFinish!!!:"+auditResult+" code:"+code+" msg:"+msg);
                    channel.invokeMethod("RPVerifyFinish",new HashMap<String, Object>() {
                        {
                            put("callId", callId);
                            put("token", token);
                            put("result", resultTemp);
                            put("resultCode", resultCodeTemp);
                            put("resultMsg", resultMsgTemp);
                        }
                    }, new MethodChannel.Result() {
                        @Override
                        public void error(String errorCode, String errorMessage, Object errorDetails){
//              Log.e("flutter","error call");
//              Log.e("flutter",errorCode);
//              Log.e("flutter",errorMessage);
//              Log.e("flutter",errorDetails.toString());
                        }

                        @Override
                        public void success(Object result) {
                            //Log.e("flutter","success call");
                            //Log.e("flutter",result.toString());
                        }

                        @Override
                        public void notImplemented() {
                            Log.e("flutter","notImplemented call");
                        }
                    });
                }
            };
            if (isNative!=null && isNative==true) {
                if (skinPath!= null) {
                    RPConfig.Builder configBuilder = new RPConfig.Builder()
                            .setSkinInAssets(skinInAssets==true) // 是否是内置皮肤
                            .setSkinPath(skinPath); // 设置皮肤路径
                    RPConfig config = configBuilder.build();
                    RPVerify.startByNative(activity,token,config,listener);
                } else {
                    RPVerify.startByNative(activity,token,listener);
                }
            } else {
                if (skinPath!= null) {
                    RPConfig.Builder configBuilder = new RPConfig.Builder()
                            .setSkinInAssets(skinInAssets==true) // 是否是内置皮肤
                            .setSkinPath(skinPath); // 设置皮肤路径
                    RPConfig config = configBuilder.build();
                    RPVerify.start(activity,token,config,listener);
                } else {
                    RPVerify.start(activity,token,listener);
                }
            }

            result.success(packResult("ok", "ok", new HashMap<String,Object>() { { } }));
        } else if (call.method.equals("startAuth")) {
            final String token = call.argument("token");
            final int callId = call.argument("callId");
            if(activity == null) {
                result.success(packResult("fail", "fail", new HashMap<String,Object>(){{
                }}));
            }
            Log.e("flutter","call RPVerify.start now!!!");
            RPVerify.start(activity, token, new RPEventListener() {
                @Override
                public void onFinish(RPResult auditResult,String code,String msg) {
                    int resultCode = 0;
                    if (auditResult == RPResult.AUDIT_PASS) {
                        // 认证通过。建议接入方调用实人认证服务端接口DescribeVerifyResult来获取最终的认证状态，并以此为准进行业务上的判断和处理。
                        // do something
                        resultCode = 1;
                    } else if (auditResult == RPResult.AUDIT_FAIL) {
                        // 认证不通过。建议接入方调用实人认证服务端接口DescribeVerifyResult来获取最终的认证状态，并以此为准进行业务上的判断和处理。
                        // do something
                        resultCode = -1;
                    } else if (auditResult == RPResult.AUDIT_NOT) {
                        // 未认证，具体原因可通过code来区分（code取值参见错误码说明），通常是用户主动退出或者姓名身份证号实名校验不匹配等原因，导致未完成认证流程。
                        // do something
                        resultCode = 0;
                    }
                    final int resultTemp = resultCode;
                    final String resultCodeTemp = code;
                    final String resultMsgTemp = msg;
                    Log.e("flutter","onFinish!!!:"+auditResult+" code:"+code+" msg:"+msg);
                    channel.invokeMethod("RPVerifyFinish",new HashMap<String, Object>() {
                        {
                            put("callId", callId);
                            put("token", token);
                            put("result", resultTemp);
                            put("resultCode", resultCodeTemp);
                            put("resultMsg", resultMsgTemp);
                        }
                    }, new MethodChannel.Result() {
                        @Override
                        public void error(String errorCode, String errorMessage, Object errorDetails){
//              Log.e("flutter","error call");
//              Log.e("flutter",errorCode);
//              Log.e("flutter",errorMessage);
//              Log.e("flutter",errorDetails.toString());
                        }

                        @Override
                        public void success(Object result) {
//              Log.e("flutter","success call");
//              Log.e("flutter",result.toString());
                        }

                        @Override
                        public void notImplemented() {
//              Log.e("flutter","notImplemented call");
                        }
                    });


                }
            });
            result.success(packResult("ok", "ok", new HashMap<String,Object>() { { } }));
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
