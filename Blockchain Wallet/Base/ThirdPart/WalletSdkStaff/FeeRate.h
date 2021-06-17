//
//  FeeRate.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/29.
//

#import <Foundation/Foundation.h>
#import <walletsdk/walletsdk.h>

NS_ASSUME_NONNULL_BEGIN

@interface FeeRate : NSObject<ApiEstimateTransactionSizeCallback>

typedef void(^WalletSdkFeeRateBlock)(NSString *size, NSString *errorStr);

@property (nonatomic, copy) WalletSdkFeeRateBlock feeRateBlock;

@end

NS_ASSUME_NONNULL_END
