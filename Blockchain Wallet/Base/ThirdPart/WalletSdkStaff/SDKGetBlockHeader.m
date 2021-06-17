//
//  SDKGetBlockHeader.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/31.
//

#import "SDKGetBlockHeader.h"

@implementation SDKGetBlockHeader

- (void)success:(ApiGetBlockHeaderResponse *)p0{

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.getHeaderBlock) {
            self.getHeaderBlock(p0.height, @"");
        }
    });
}
- (void)failure:(NSError *)err{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.getHeaderBlock) {
            self.getHeaderBlock(@"", err.localizedDescription);
        }
    });
}

@end
