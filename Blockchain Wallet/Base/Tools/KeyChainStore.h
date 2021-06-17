//
//  KeyChainStore.h
//  cocolion
//
//  Created by panerly on 2019/3/20.
//  Copyright © 2019 panerly. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KeyChainStore : NSObject

+ (void)save:(NSString *)service data:(id)data;

+ (id)load:(NSString *)service;

+ (void)deleteKeyData:(NSString *)service;

@end

NS_ASSUME_NONNULL_END
