//
//  RemoveKeyTool.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/31.
//

#import <Foundation/Foundation.h>
#import <walletsdk/walletsdk.h>

NS_ASSUME_NONNULL_BEGIN

@interface RemoveKeyTool : NSObject<ApiRemoveKeyCallback>

typedef void(^WalletSdkRemoveKeyBlock)(NSString *keyId, NSString *errorStr);

@property (nonatomic, copy) WalletSdkRemoveKeyBlock removeKeyBlock;

@end

NS_ASSUME_NONNULL_END
