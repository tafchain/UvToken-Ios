//
//  WalletModel.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WalletModel : NSObject<NSSecureCoding>

@property (nonatomic, strong) NSString<Optional> *name;
@property (nonatomic, strong) NSString<Optional> *mnemonics;
@property (nonatomic, strong) NSString<Optional> *password;
@property (nonatomic, strong) NSString<Optional> *privateKey;
@property (nonatomic, strong) NSString<Optional> *publicKey;

@end

NS_ASSUME_NONNULL_END
