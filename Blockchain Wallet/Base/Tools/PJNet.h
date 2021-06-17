//
//  PJNet.h
//  cocolion
//
//  Created by panerly on 2018/7/30.
//  Copyright © 2018 panerly. All rights reserved.
//

#import <Foundation/Foundation.h>

enum HTTPMETHOD{
    METHOD_GET = 0, //GET请求
    METHOD_POST = 1,  //POST请求
};

@interface PJNet : NSObject

@property (nonatomic,copy) NSString *hostIP;
/**
 * 默认POST请求 timeout = 10.0s
 */
+ (void)requestAFURL:(NSString *)URLString
          parameters:(id)parameters
              method:(NSInteger )method
             succeed:(void (^) (id result))succeed
             failure:(void (^) (NSError *error)) failure;
//+ (void)requestURL:(NSString *)URLString
//        httpMethod:(NSInteger) method
//        parameters:(id)parameters
//           timeOut:(NSTimeInterval) timeOut
//           succeed:(void (^) (id))succeed
//           failure:(void (^) (NSError *)) failure;


+ (void)uploadFileWithURL:(NSString *)URLString Parameters:(id)parameters ImgArr:(NSArray<UIImage *> *)imgArr uploadImgProgress:(nullable void (^)(NSProgress * _Nonnull))uploadImgProgress Success:(void (^) (id result))succeed Failure:(void (^) (NSError *error))failure;

@end
