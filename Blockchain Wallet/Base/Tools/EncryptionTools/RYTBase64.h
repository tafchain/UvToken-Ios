//
//  RYTBase64.h
//  SMSCodeTest
//
//  Created by timmy on 16/10/19.
//  Copyright © 2016年 任雨婷. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RYTBase64 : NSObject

//Base64
+ (NSString *)base64StringFromText:(NSString *)text;
+ (NSString *)textFromBase64String:(NSString *)base64;
+ (NSString *)base64EncodedStringFrom:(NSData *)data;

@end
