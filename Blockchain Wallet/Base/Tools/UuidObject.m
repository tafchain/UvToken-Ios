//
//  UuidObject.m
//  cocolion
//
//  Created by panerly on 2019/3/20.
//  Copyright © 2019 panerly. All rights reserved.
//

#import "UuidObject.h"
#import "KeyChainStore.h"

@implementation UuidObject

+(NSString *)getUUID
{
    NSString * strUUID = (NSString *)[KeyChainStore load:@"com.vbhledger.Taft"];
    
    //首次执行该方法时，uuid为空
    
    if ([strUUID isEqualToString:@""] || !strUUID)
        
    {
        //生成一个uuid的方法
        
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        
        //将该uuid保存到keychain
        
        [KeyChainStore save:@"com.vbhledger.Taft" data:strUUID];
        
    }
    return strUUID;
}
@end
