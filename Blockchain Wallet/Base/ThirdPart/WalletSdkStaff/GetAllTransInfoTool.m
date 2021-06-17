//
//  GetAllTransInfoTool.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/31.
//

#import "GetAllTransInfoTool.h"

@implementation GetAllTransInfoTool

- (void)success:(ApiGetAddressesTxIdsResponse *)p0{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.getTransInfoBlock) {
            self.getTransInfoBlock(p0.txIds, @"");
        }
    });
}

- (void)failure:(NSError *)err{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.getTransInfoBlock) {
            self.getTransInfoBlock(@"", err.localizedDescription);
        }
    });
}

@end
