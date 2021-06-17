//
//  SDKTransTool.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/28.
//

#import <Foundation/Foundation.h>
#import <walletsdk/Walletsdk.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDKTransTool : NSObject<ApiTransferCallback>

typedef void(^WalletSdkTransBlock)(NSString *coinType, NSString *keyId, NSString *txId, NSString *errorStr);

@property (nonatomic, copy) WalletSdkTransBlock transBlock;

@end

NS_ASSUME_NONNULL_END
