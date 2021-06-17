//
//  SDKCreatWallet.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/20.
//

#import <Foundation/Foundation.h>
#import <walletsdk/walletsdk.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDKCreatWallet : NSObject<ApiCreateWalletCallback>

typedef void(^CreateWalletBlock)(NSString *successStr ,NSString *errorStr);

@property (nonatomic, copy) CreateWalletBlock createWalletBlock;

@end

NS_ASSUME_NONNULL_END
