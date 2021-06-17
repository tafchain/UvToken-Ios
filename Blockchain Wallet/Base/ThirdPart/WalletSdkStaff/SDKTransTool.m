//
//  SDKTransTool.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/28.
//

#import "SDKTransTool.h"

@implementation SDKTransTool

- (void)success:(ApiTransferResponse *)p0{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.transBlock) {
            self.transBlock(p0.coinType, p0.keyId, p0.txId, @"");
        }
    });
}

- (void)failure:(NSError *)err{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
            if (self.transBlock) {
                self.transBlock(@"", @"", @"", err.localizedDescription);
            }
    });
}

@end
