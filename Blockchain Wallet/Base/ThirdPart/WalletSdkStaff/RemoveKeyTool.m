//
//  RemoveKeyTool.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/31.
//

#import "RemoveKeyTool.h"

@implementation RemoveKeyTool

- (void)success:(ApiRemoveKeyResponse *)p0{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.removeKeyBlock) {
            self.removeKeyBlock(p0.keyIds, @"");
        }
    });
}

- (void)failure:(NSError *)err{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.removeKeyBlock) {
            self.removeKeyBlock(@"", err.localizedDescription);
        }
    });
}

- (void)onProgress:(NSString * _Nullable)keyId {
    dispatch_async(dispatch_get_main_queue(), ^{
        DLog(@"%@", keyId);
    });
}


@end
