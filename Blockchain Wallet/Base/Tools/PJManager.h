//
//  PJManager.h
//  cocolion
//
//  Created by panerly on 2018/7/30.
//  Copyright © 2018 panerly. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface PJManager : AFHTTPSessionManager

+ (AFHTTPSessionManager *)shareManager;

@end
