#import "FlutterAliCloudAuthPlugin.h"
#import <RPSDK/RPSDK.h>

@implementation FlutterAliCloudAuthPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterAliCloudAuthPlugin* instance = [[FlutterAliCloudAuthPlugin alloc] init];
    [RPSDK setup];
    instance.channel = [FlutterMethodChannel
                        methodChannelWithName:@"flutter_ali_cloud_auth"
                              binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:instance.channel];
  
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  __weak typeof(self) weakSelf = self;
  
  if ([@"startAuth" isEqualToString:call.method]) {
    RPConfiguration *configuration = [RPConfiguration configuration];

    NSLog(@"handleMethodCall: %@",[call description]);
    if ([call.arguments objectForKey:@"token"] != nil) {
      NSLog(@"token: %@",[[call.arguments objectForKey:@"token"] description]);
    } else {
        result(@{@"code":@"fail",@"msg":@"fail,no token",@"data":@{}});
        return;
    }
    if ([call.arguments objectForKey:@"callId"] != nil) {
      NSLog(@"callId: %@",[call.arguments[@"callId"] description]);
    }
    
    NSLog(@"native: %@",[call.arguments objectForKey:@"native"]);
    
    if ([call.arguments objectForKey:@"skinPath"] != nil) {
        NSLog(@"skinPath: %@",[call.arguments[@"skinPath"] description]);
        configuration.customUIPath = call.arguments[@"skinPath"];  
    }
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
      void(^completionBlock)(RPResult * _Nonnull result);
      completionBlock= ^(RPResult * _Nonnull result){
            NSLog(@"实人认证结果：%@", result);
//            switch (result.state) {
//                case RPStatePass:
//                    // 认证通过。
//                    break;
//                case RPStateFail:
//                    // 认证不通过。
//                    break;
//                case RPStateNotVerify:
//                    // 未认证。
//                    // 通常是用户主动退出或者姓名身份证号实名校验不匹配等原因导致。
//                    // 具体原因可通过result.errorCode来区分（详见文末错误码说明表格）。
//                    break;
//            };
          [weakSelf.channel invokeMethod: @"RPVerifyFinish" arguments:@{
              @"callId":call.arguments[@"callId"],
              @"token":call.arguments[@"token"],
              @"result":[NSNumber numberWithInteger: result.state],
              @"resultCode":result.errorCode,
              @"resultMsg":@""} result: ^(id _Nullable result) {
                        NSLog(@"result: %@",[result description]);
                    }];
          NSLog(@"try call RPVerifyFinish from native");
      };
      if ([[call.arguments objectForKey:@"native"]  isEqual: @1] ) {
          NSLog(@"startNative");
          [RPSDK startByNativeWithVerifyToken:call.arguments[@"token"]
               viewController:rootViewController
                              configuration:(RPConfiguration *)configuration
                                   progress:nil
                   completion: completionBlock];
        } else {
            NSLog(@"startAuth");
            [RPSDK startWithVerifyToken:call.arguments[@"token"]
                 viewController:rootViewController
                    configuration:(RPConfiguration *)configuration
                     completion: completionBlock];
        }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
