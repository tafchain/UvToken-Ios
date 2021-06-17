//
//  RYTAESEncryptor.h
//  SMSCodeTest
//
//  Created by timmy on 16/10/19.
//  Copyright © 2016年 任雨婷. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RYTAESEncryptor : NSObject

//AES加密
+ (NSData *)AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv withNSData:(NSData *)data;

//AES解密
+ (NSData *)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv withNSData:(NSData *)data;

@end
