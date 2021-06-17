//
//  SDKImportMnemonic.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/20.
//

#import <Foundation/Foundation.h>
#import <walletsdk/walletsdk.h>
NS_ASSUME_NONNULL_BEGIN

@interface SDKImportMnemonic : NSObject<ApiImportWalletFromMnemonicCallback>

typedef void(^WalletSdkBlock)(NSString *successStr, NSString *errorStr, NSString *keyID, NSString *coinType, NSString *walletID, NSString *addressStr);

@property (nonatomic, copy) WalletSdkBlock importMnemonicBlock;

@end

NS_ASSUME_NONNULL_END
