//
//  RYTMD5Encryptor.h
//  SMSCodeFramework
//
//  Created by timmy on 16/11/1.
//  Copyright © 2016年 timmy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RYTMD5Encryptor : NSObject

+ (NSString *)stringTo32BitsLowcaseMD5:(NSString *)inputStr;

+ (NSString *)stringTo32BitsUppercaseMD5:(NSString *)inputStr;

@end
