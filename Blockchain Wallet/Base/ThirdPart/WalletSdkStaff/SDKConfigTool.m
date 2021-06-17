//
//  SDKConfigTool.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/4/2.
//

#import "SDKConfigTool.h"

@implementation SDKConfigTool

- (void)success:(ApiParamResponse *)p0{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.configBlock) {
            self.configBlock(p0.httpUrl, p0.net);
            DLog(@"%@ --- %@", p0.httpUrl, p0.net);
        }
    });
}

- (void)failure:(NSError *)err{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.configBlock) {
            self.configBlock(@"", @"");
        }
    });
}

@end
