//
//  FeeRate.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/29.
//

#import "FeeRate.h"

@implementation FeeRate

- (void)success:(ApiEstimateTransactionSizeResponse *)p0{

    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *size = [NSString stringWithFormat:@"%ld", p0.size];
        if (self.feeRateBlock) {
            self.feeRateBlock(size, @"");
        }
    });
}
- (void)failure:(NSError *)err{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.feeRateBlock) {
            self.feeRateBlock(@"", err.localizedDescription);
        }
    });
}

@end
