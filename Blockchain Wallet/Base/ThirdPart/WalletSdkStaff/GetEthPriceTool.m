//
//  GetEthPriceTool.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/2/4.
//

#import "GetEthPriceTool.h"

@implementation GetEthPriceTool

- (void)success:(ApiEstimateEthGasPriceResponse *)p0{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.getEthFeeRateBlock) {
            self.getEthFeeRateBlock(p0.feeRate, @"");
        }
    });
}

- (void)failure:(NSError *)err{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.getEthFeeRateBlock) {
            self.getEthFeeRateBlock(0, @"");
        }
    });
}

@end
