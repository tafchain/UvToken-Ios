//
//  SDKGetBTCDetailTool.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/4/2.
//

#import "SDKGetBTCDetailTool.h"

@implementation SDKGetBTCDetailTool

- (void)success:(ApiGetBtcTransactionResponse *)p0{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.btcTransBlock) {
            self.btcTransBlock([NSString stringWithFormat:@"%lld", p0.confirmations], [NSString stringWithFormat:@"%d", p0.trusted], @"");
        }
    });
}

- (void)failure:(NSError *)err{
    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self.btcTransBlock) {
//            self.btcTransBlock(@"", @"", err.localizedDescription);
//        }
    });
}

@end
