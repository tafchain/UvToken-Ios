//
//  SDKCheckAddrTool.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/4/2.
//

#import "SDKCheckAddrTool.h"

@implementation SDKCheckAddrTool

- (void)success:(ApiValidateAddressResponse *)p0{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.validateBlock) {
            self.validateBlock(p0.valid, @"");
        }
    });
}
- (void)failure:(NSError *)err{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.validateBlock) {
            self.validateBlock(NO, err.localizedDescription);
        }
    });
}

@end
