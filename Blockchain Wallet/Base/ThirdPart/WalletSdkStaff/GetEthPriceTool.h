//
//  GetEthPriceTool.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/2/4.
//

#import <Foundation/Foundation.h>
#import <walletsdk/Walletsdk.h>

NS_ASSUME_NONNULL_BEGIN

@interface GetEthPriceTool : NSObject<ApiEstimateEthGasPriceCallback>

typedef void(^SDKGetEthFeeRateBlock)(NSString *feeRate, NSString *errorStr);

@property (nonatomic, copy) SDKGetEthFeeRateBlock getEthFeeRateBlock;

@end

NS_ASSUME_NONNULL_END
