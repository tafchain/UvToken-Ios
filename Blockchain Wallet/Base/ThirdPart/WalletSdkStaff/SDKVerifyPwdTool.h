//
//  SDKVerifyPwdTool.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/4/19.
//

#import <Foundation/Foundation.h>
#import <walletsdk/Walletsdk.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDKVerifyPwdTool : NSObject

typedef void(^SDKVerifyPwdBlock)(NSString *confirmations, NSString *trusted, NSString *errorStr);

@property (nonatomic, copy) SDKVerifyPwdBlock verifyPwdBlock;

@end

NS_ASSUME_NONNULL_END
