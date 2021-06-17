//
//  PJManager.m
//  cocolion
//
//  Created by panerly on 2018/7/30.
//  Copyright © 2018 panerly. All rights reserved.
//

#import "PJManager.h"

@implementation PJManager
static AFHTTPSessionManager *sharedManager;

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (AFHTTPSessionManager *)shareManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
//        sharedManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:sessionConfig];
        sharedManager = [AFHTTPSessionManager manager];
        [sharedManager.requestSerializer setTimeoutInterval:60];
        sharedManager.responseSerializer = [AFJSONResponseSerializer serializer];
//        [sharedManager.requestSerializer setValue:@"application/x-www-form-urlencode" forHTTPHeaderField:@"Content-Type"];
//        [sharedManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
    });
    return sharedManager;
}

@end
