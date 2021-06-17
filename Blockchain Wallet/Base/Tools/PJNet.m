//
//  PJNet.m
//  cocolion
//
//  Created by panerly on 2018/7/30.
//  Copyright © 2018 panerly. All rights reserved.
//

#import "PJNet.h"
#import "PJManager.h"

@implementation PJNet

/**
 * 默认POST请求 timeout = 10.0s
 */
+ (void)requestAFURL:(NSString *)URLString
          parameters:(id)parameters
              method:(NSInteger )method
             succeed:(void (^) (id result))succeed
             failure:(void (^) (NSError *error)) failure
{
    [self requestURL:URLString httpMethod:method parameters:parameters timeOut:30 succeed:^(id result) {
        succeed(result);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)requestURL:(NSString *)URLString
          httpMethod:(NSInteger) method
          parameters:(id)parameters
             timeOut:(NSTimeInterval) timeOut
             succeed:(void (^) (id))succeed
             failure:(void (^) (NSError *)) failure
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.bezelView.color = [UIColor blackColor];
    hud.label.text = Localized(@"loadingStr");
    hud.label.textColor = [UIColor whiteColor];
//    hud.activityIndicatorColor = [UIColor whiteColor];
    
    
    AFHTTPResponseSerializer *serializer = [PJManager shareManager].responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    
    AFHTTPSessionManager *manager = [PJManager shareManager];
    
    //网络请求
    if (method == METHOD_GET) {
        
        NSURLSessionTask *task = [manager GET:URLString parameters:parameters headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [hud hideAnimated:YES];
            
            succeed(responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [hud hideAnimated:YES];
            
            failure(error);
        }];
        
        [task resume];
        
    }else if (method == METHOD_POST){
        
        NSURLSessionTask *task = [manager POST:URLString parameters:parameters headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [hud hideAnimated:YES];
            
            succeed(responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [hud hideAnimated:YES];
            
            failure(error);
            
        }];
        
        [task resume];
    }
}

+ (void)uploadFileWithURL:(NSString *)URLString Parameters:(id)parameters ImgArr:(NSArray<UIImage *> *)imgArr uploadImgProgress:(nullable void (^)(NSProgress * _Nonnull))uploadImgProgress Success:(void (^)(id))succeed Failure:(void (^)(NSError *))failure{
    
    
    [SVProgressHUD showWithStatus:Localized(@"uploading")];
    
    AFHTTPSessionManager *manager = [PJManager shareManager];
    
    NSString *token = (NSString *)[PTool getValueFromKey:@"token"];
    NSDictionary *header = @{@"token":token?token:@""};
    
    [manager POST:URLString parameters:parameters headers:header constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (int i = 0; i < imgArr.count; i++) {
            
            NSData *imageData = UIImagePNGRepresentation(imgArr[i]);
            /**
             拼接文件参数
             
             @fileData : 要上传的文件数据
             @name : 后台定义文件的参数名
             @fileName ： 上传到服务器的文件名称
             @mimeType : 上传的文件类型
             */
            NSString *imgName = [NSString stringWithFormat:@"%@-%d.jpeg", [PTool getNowTimeTimestamp], i];
            DLog(@"imgName:%@",imgName);
            [formData appendPartWithFileData:imageData name:i==0?@"id_front":@"id_back" fileName:imgName mimeType:@"image/jpeg"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CGFloat progressValue = 1.0 *
            uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
            
            if (progressValue < 1) {
                
                [SVProgressHUD showProgress:progressValue status:Localized(@"uploading")];
            }else{
                
                [SVProgressHUD showWithStatus:Localized(@"uploadSuccessStr")];
            }
        });
        
        uploadImgProgress(uploadProgress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [SVProgressHUD dismiss];
        succeed(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        [SVProgressHUD dismiss];
        
        if (error.code == -1001 || [error.localizedDescription isEqualToString:@"Request failed: unauthorized (401)"]) {
            
            [PJHud showWithString:Localized(@"reloginAlertStr") BackGroudnColor:COLORRGB(228, 102, 96) loading:NO duration:2 AutoHide:YES];

            [PTool saveValue:@"" forKey:@"emailAddr"];
            [PTool saveValue:@"" forKey:@"token"];
            [PTool saveValue:@"NO" forKey:logStatus];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGINOFFSELECTCENTERINDEX object:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PRENSENTLOGIN object:nil];
        }else{
            
            failure(error);
        }
        
    }];
    
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
            
            [PJHud showWithString:Localized(@"reloginAlertStr") BackGroudnColor:COLORRGB(228, 102, 96) loading:NO duration:2 AutoHide:YES];

            [PTool saveValue:@"" forKey:@"emailAddr"];
            [PTool saveValue:@"" forKey:@"token"];
            [PTool saveValue:@"NO" forKey:logStatus];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGINOFFSELECTCENTERINDEX object:nil];
            
            break;
            
            
        default:
            
            [LSStatusBarHUD showMessageAndImage:Localized(@"retryAlertStr")];
            break;
    }
}
@end
