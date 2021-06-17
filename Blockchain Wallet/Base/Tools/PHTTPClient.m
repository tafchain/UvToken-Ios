//
//  PHTTPClient.m
//  Taft
//
//  Created by panerly on 2020/11/23.
//  Copyright © 2020 panerly. All rights reserved.
//

#import "PHTTPClient.h"
#import "PJManager.h"

@implementation PHTTPClient

+ (instancetype)shareInstance
{
    static PHTTPClient *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[PHTTPClient alloc] init];
    });
    return singleton;
}

- (void)startRequestMethod:(NSInteger)method parameters:(id)parameters url:(NSString *)url success:(void (^)(id _Nonnull))success{
    
    [SVProgressHUD showWithStatus:Localized(@"loadingStr")];
    if ([url containsString:@"/user/login"] || [url containsString:@"/user/pk"]) {
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    }else{
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    }
    
    //1、初始化：
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFHTTPSessionManager *manager = [PJManager shareManager];
    
    //2、设置请求超时时间：
    manager.requestSerializer.timeoutInterval = 30.0f;
    //2、设置允许接收返回数据类型：
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", nil];
    
    NSString *token = (NSString *)[PTool getValueFromKey:@"token"];
    
    DLog(@"%@", token);

//    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];//手机系统版本
//    NSString *platformString = [NSString stringWithFormat:@"%@ %@", [PTool platformString], phoneVersion];//手机型号
//
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    CFShow((__bridge CFTypeRef)(infoDictionary));
//    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
//
//    NSString *uuid_string = [PTool getUUID];
//    
//    //设置公共参数
//    [parameters setObject:platformString forKey:@"phone_type"]; //手机型号
//    [parameters setObject:uuid_string forKey:@"device_uuid"];   //设备唯一识别码
//    [parameters setObject:app_Version forKey:@"app_version"];   //当前APP版本号
//    [parameters setObject:@"iPhone" forKey:@"brand"];           //手机品牌
//    [parameters setObject:phoneVersion forKey:@"os_version"];   //系统版本
    
    PWS(weakSelf);
    
    if (method == GET) {
        
        [manager GET:url parameters:parameters headers:@{@"token":token?token:@"error"} progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [SVProgressHUD dismiss];
            
            if (success) {
                
                success(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [SVProgressHUD dismiss];
            
            [weakSelf requestFailed:error];
        }];
    }else{
        
        [manager POST:url parameters:parameters headers:@{@"token":token?token:@"error"} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [SVProgressHUD dismiss];
            
            if (success) {
                
                NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                if (code == 0) {
                    
                    success(responseObject);
                }else{
                    
                    [weakSelf respondsCodeError:code];
                }
            }
            
            [weakSelf resetToken:task];
            
            [weakSelf setUserLogWithRequestUrl:url];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [SVProgressHUD dismiss];
            [weakSelf requestFailed:error];
        }];
    }
    
}

- (void)startRequestMethod:(NSInteger)method parameters:(id)parameters url:(NSString *)url success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure{
    
    [SVProgressHUD showWithStatus:Localized(@"loadingStr")];
    
    //1、初始化：
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFHTTPSessionManager *manager = [PJManager shareManager];
    //2、设置请求超时时间：
    manager.requestSerializer.timeoutInterval = 30.0f;
    //2、设置允许接收返回数据类型：
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", nil];
    
    NSString *token = (NSString *)[PTool getValueFromKey:@"token"];

//    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];//手机系统版本
//    NSString *platformString = [NSString stringWithFormat:@"%@ %@", [PTool platformString], phoneVersion];//手机型号
//
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    CFShow((__bridge CFTypeRef)(infoDictionary));
//    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
//
//    NSString *uuid_string = [PTool getUUID];
//
//    //设置公共参数
//    [parameters setObject:platformString forKey:@"phone_type"]; //手机型号
//    [parameters setObject:uuid_string forKey:@"device_uuid"];   //设备唯一识别码
//    [parameters setObject:app_Version forKey:@"app_version"];   //当前APP版本号
//    [parameters setObject:@"iPhone" forKey:@"brand"];           //手机品牌
//    [parameters setObject:phoneVersion forKey:@"os_version"];   //系统版本
    
    PWS(weakSelf);
    
    if (method == GET) {
        
        [manager GET:url parameters:parameters headers:@{@"token":token?token:@"error"} progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [SVProgressHUD dismiss];
            if (success) {
                
                NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                if (code == 0) {
                    
                    success(responseObject);
                }else{
                    
                    [weakSelf respondsCodeError:code];
                }
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [SVProgressHUD dismiss];
            if (failure) {
                failure(error);
            }
        }];
    }else{
        
        [manager POST:url parameters:parameters headers:@{@"token":token?token:@"error"} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [SVProgressHUD dismiss];
            
            if (success) {
                
                NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                if (code == 0) {
                    
                    success(responseObject);
                }else{
                    
                    [weakSelf respondsCodeError:code];
                }
            }
            
            [weakSelf resetToken:task];
            
            [weakSelf setUserLogWithRequestUrl:url];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [SVProgressHUD dismiss];
            
            if (failure) {
                
                failure(error);
            }
        }];
    }
}

- (void)requestMethod:(NSInteger)method parameters:(id)parameters url:(NSString *)url success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure{
    
    //1、初始化：
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFHTTPSessionManager *manager = [PJManager shareManager];
    //2、设置请求超时时间：
    manager.requestSerializer.timeoutInterval = 10.0f;
    //2、设置允许接收返回数据类型：
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", nil];
    
    NSString *token = (NSString *)[PTool getValueFromKey:@"token"];
    
    PWS(weakSelf);
    
    if (method == GET) {
        
        [manager GET:url parameters:parameters headers:@{@"token":token?token:@"error"} progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (success) {
                success(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [SVProgressHUD dismiss];
            if (failure) {
                failure(error);
            }
        }];
    }else{
        
        [manager POST:url parameters:parameters headers:@{@"token":token?token:@"error"} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        
            if (success) {
                
                NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
                if (code == 0) {
                    
                    success(responseObject);
                }else{
                    
                    [weakSelf respondsCodeError:code];
                }
            }
            
            [weakSelf resetToken:task];
            
            [weakSelf setUserLogWithRequestUrl:url];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [SVProgressHUD dismiss];
            if (failure) {
                
                failure(error);
                if ([url containsString:@"dailycount"]) {
                    DLog(@"日活接口调用失败%@", error.localizedDescription);
                }else{
                    
                    [weakSelf requestFailed:error];
                }
            }
        }];
    }
}


- (void)bodyRequestMethod:(NSInteger)method parameters:(id)parameters url:(NSString *)url success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure{
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters
                                                       options:NSJSONWritingPrettyPrinted  error:nil];

    //afn请求
    AFURLSessionManager *manager = [AFHTTPSessionManager manager];

    NSString * requestUrl  = url;
    //如果你不需要在请求体里传参 那就参数放入parameters里面
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer]
                                    requestWithMethod:@"POST" URLString:requestUrl parameters:nil error:nil];

    DLog(@"requestURL:%@  param：%@", requestUrl, parameters);
    request.timeoutInterval = 10;

    //这句话很重要，设置"Content-Type"类型 json类型跟后台大哥的一致
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // 设置参数放入到body请求体里。
    [request setHTTPBody:jsonData];

    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                 @"text/html",@"text/json", @"text/javascript",@"text/plain",nil];

    manager.responseSerializer = responseSerializer;
    
    [[manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil
                completionHandler:^(NSURLResponse *response,id responseObject,NSError *error){

        if(responseObject!=nil){
            NSString *result = [[NSString alloc] initWithData:responseObject
                       encoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
            success(dic);
        }else{
            failure(error);
        }

    }] resume];
}


- (void)resetToken:(NSURLSessionDataTask *)task{

    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    NSDictionary *allHeaders = response.allHeaderFields;
    
    NSString *refresh_token = [NSString stringWithFormat:@"%@", [allHeaders objectForKey:@"Refresh-Token"]];
    
    if (refresh_token.length > 6) {//排除"(null)"字符串
        
        DLog(@"已经重置token%@", refresh_token);
        [PTool saveValue:refresh_token forKey:@"token"];
    }
}

//实现请求失败回调方法
- (void)requestFailed:(NSError *)error
{
    NSLog(@"--------------\n%ld %@",(long)error.code, error.debugDescription);
    switch (error.code) {
        case AFNetworkErrorType_NotNetwork :
            NSLog(@"网络链接失败，请检查网络。");
            [PJHud showWithString:Localized(@"connectErrorStr") BackGroudnColor:COLORRGB(228, 102, 96) loading:NO duration:2 AutoHide:YES];
            break;
        case AFNetworkErrorType_TimeOut :
            NSLog(@"访问服务器超时，请检查网络。");
            [PJHud showWithString:Localized(@"timeOutStr") BackGroudnColor:COLORRGB(228, 102, 96) loading:NO duration:2 AutoHide:YES];
            break;
        case AFNetworkErrorType_3840Failed :
            NSLog(@"服务器报错了，请稍后再访问。");
            [PJHud showWithString:Localized(@"serverErrorStr") BackGroudnColor:COLORRGB(228, 102, 96) loading:NO duration:2 AutoHide:YES];
            break;
        case -1011 :
            
#warning taf方法
            break;
            [PJHud showWithString:Localized(@"reloginAlertStr") BackGroudnColor:COLORRGB(228, 102, 96) loading:NO duration:2 AutoHide:YES];

            [PTool saveValue:@"error" forKey:@"emailAddr"];
            [PTool saveValue:@"error" forKey:@"token"];
            [PTool saveValue:@"NO" forKey:logStatus];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TAFLOGOFF object:nil];
            break;
            
        default:
            
            [LSStatusBarHUD showMessageAndImage:Localized(@"retryAlertStr")];
            break;
    }
}

- (void)respondsCodeError:(NSInteger)code{
    
    NSString *errorStr = Localized(@"errorRequestFailedStr");//请求失败
    
    if (code == 100101) {//参数错误
        
        errorStr = Localized(@"error100101");
    }else if (code == 100104){//邮箱格式不正确
        
        errorStr = Localized(@"error100104");
    }else if (code == 100111){//验证码错误
        
        errorStr = Localized(@"error100111");
    }else if (code == 100112){//验证码过期
        
        errorStr = Localized(@"error100112");
    }else if (code == 100113){//验证码错误
        
        errorStr = Localized(@"error100113");
    }else if (code == 100115){//邀请码不存在
        
        errorStr = Localized(@"error100115");
    }else if (code == 100116){//邮箱已注册
        
        errorStr = Localized(@"error100116");
    }else if (code == 100201){//参数错误
        
        errorStr = Localized(@"error100201");
    }else if (code == 100202){//登录失败
        
        errorStr = Localized(@"error100202");
    }else if (code == 100203){//登录失败
        
        errorStr = Localized(@"error100203");
    }else if (code == 101504){//新旧密码不能相同
        
        errorStr = Localized(@"error101504");
    }else if (code == 101701){//参数错误
        
        errorStr = Localized(@"error101701");
    }else if (code == 101702){//获取失败
        
        errorStr = Localized(@"error101702");
    }else if (code == 101703){//获取验证码太频繁
        
        errorStr = Localized(@"error101703");
    }else if (code == 101704){//邮箱已被注册
        
        errorStr = Localized(@"error101704");
    }else if (code == 102002){//超出预售额度限制
        
        errorStr = Localized(@"error102002");
    }else if (code == 102003){//获取地址失败
        
        errorStr = Localized(@"error102003");
    }else if (code == 102101){//证件类型输入错误
        
        errorStr = Localized(@"error102101");
    }else if (code == 102102){//参数错误
        
        errorStr = Localized(@"error102102");
    }else if (code == 102103){//参数错误
        
        errorStr = Localized(@"error102103");
    }else if (code == 102104){//参数错误
        
        errorStr = Localized(@"error102104");
    }else if (code == 102105){//证件正面照片上传失败
        
        errorStr = Localized(@"error102105");
    }else if (code == 102106){//证件背面照片上传失败
        
        errorStr = Localized(@"error102106");
    }else if (code == 102601){//参数错误
        
        errorStr = Localized(@"error102601");
    }else if (code == 102602){//转让失败
        
        errorStr = Localized(@"error102602");
    }else if (code == 102603){//用户不存在
        
        errorStr = Localized(@"error102603");
    }else if (code == 102604){//转账金额 <= 0
        
        errorStr = Localized(@"error102604");
    }else if (code == 102605){//余额不足
        
        errorStr = Localized(@"error102605");
    }else if (code == 102606){//转让用户不能为自己
        
        errorStr = Localized(@"error102606");
    }else if (code == 102607){//转让对方未KYC认证
        
        errorStr = Localized(@"error102607");
    }else if (code == 102801){//参数错误
        
        errorStr = Localized(@"error102801");
    }else if (code == 102802){//获取失败
        
        errorStr = Localized(@"error102802");
    }else if (code == 102803){//获取验证码太频繁
        
        errorStr = Localized(@"error102803");
    }else if (code == 103001){//授权码过期
        
        errorStr = Localized(@"error103001");
    }else if (code == 101503){//重置密码失败
        
        errorStr = Localized(@"error101503");
    }else if (code == 101505){//验证码错误
        
        errorStr = Localized(@"error101505");
    }else if (code == 101506){//验证码过期
        
        errorStr = Localized(@"error101506");
    }
    
    
    [PJHud showWithString:errorStr BackGroudnColor:COLORRGB(228, 102, 96) loading:NO duration:2 AutoHide:YES];
}

//设置用户访问日志
- (void)setUserLogWithRequestUrl:(NSString *)url{
    
    NSString *controller =NSStringFromClass([[PTool p_getCurrentVC] class]);
    DLog(@"用户访问日志-当前控制器名字:%@ url:%@ 发生时间%@", controller, url, [PTool getNowTimeTimestamp]);
}

@end
