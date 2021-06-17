//
//  SDKImportMnemonic.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/20.
//

#import "SDKImportMnemonic.h"

@implementation SDKImportMnemonic

- (void)success:(ApiImportWalletFromMnemonicResponse *)p0{
    DLog(@"%@", p0.walletId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.importMnemonicBlock) {
            self.importMnemonicBlock(p0.walletId, @"", @"", @"", @"", @"");
        }
    });
}

- (void)failure:(NSError *)err{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        DLog(@"%@", err.localizedDescription);
        if (self.importMnemonicBlock) {
            self.importMnemonicBlock(@"", err.localizedDescription, @"", @"", @"", @"");
        }
    });
}

- (void)onProgress:(NSString * _Nullable)keyId walletId:(NSString * _Nullable)walletId coinType:(NSString * _Nullable)coinType address:(NSString * _Nullable)address {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.importMnemonicBlock) {
            self.importMnemonicBlock(@"", @"", keyId, coinType, walletId, address);
        }
    });
}


@end
