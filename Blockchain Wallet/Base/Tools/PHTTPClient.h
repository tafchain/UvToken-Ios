//
//  PHTTPClient.h
//  Taft
//
//  Created by panerly on 2020/11/23.
//  Copyright © 2020 panerly. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RequestMethod) {
    GET = 0,
    POST = 1,
    PUT,
    PATCH,
    DELETE
};

typedef NS_ENUM(NSUInteger, AFNetworkErrorType){
    AFNetworkErrorType_TimeOut = NSURLErrorTimedOut,                    //-1001请求超时
    AFNetworkErrorType_UnURL = NSURLErrorUnsupportedURL,                //不支持的URL
    AFNetworkErrorType_NotNetwork = NSURLErrorNotConnectedToInternet,   //断网
    AFNetworkErrorType_404Failed = NSURLErrorBadServerResponse,         //404错误
    AFNetworkErrorType_3840Failed = 3840,                               //请求返回不是纯json格式
};

NS_ASSUME_NONNULL_BEGIN

@interface PHTTPClient : NSObject

+ (instancetype)shareInstance;


- (void)startRequestMethod:(NSInteger)method
parameters:(id)parameters
              url:(NSString *)url
      success:(void (^)(id responseObject))success;


- (void)startRequestMethod:(NSInteger)method
parameters:(id)parameters
              url:(NSString *)url
      success:(void (^)(id responseObject))success
      failure:(void (^)(NSError *error))failure;


//无加载动画
- (void)requestMethod:(NSInteger)method
parameters:(id)parameters
              url:(NSString *)url
      success:(void (^)(id responseObject))success
      failure:(void (^)(NSError *error))failure;

- (void)bodyRequestMethod:(NSInteger)method parameters:(id)parameters url:(NSString *)url success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure;
@end

NS_ASSUME_NONNULL_END
