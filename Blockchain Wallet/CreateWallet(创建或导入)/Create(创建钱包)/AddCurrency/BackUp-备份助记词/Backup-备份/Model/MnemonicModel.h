//
//  MnemonicModel.h
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MnemonicModel : NSObject<NSSecureCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *number;

@end

NS_ASSUME_NONNULL_END
