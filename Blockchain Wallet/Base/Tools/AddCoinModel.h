//
//  AddCoinModel.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/4/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddCoinModel : NSObject

@property (nonatomic, assign) int64_t coin;
@property (nonatomic, assign) int64_t account;
@property (nonatomic, assign) int64_t change;
@property (nonatomic, assign) int64_t index;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *walletID;
@property (nonatomic, strong) NSString *coinType;

//获取BTC费率 三挡
@property (nonatomic, assign) int64_t fastestFee;
@property (nonatomic, assign) int64_t halfHourFee;
@property (nonatomic, assign) int64_t hourFee;

//导入钱包
//@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *keyId;

//获取币余额
//@property (nonatomic) NSString *coinType;
@property (nonatomic) NSString *tokenType;
//@property (nonatomic) NSString *address;
@property (nonatomic) NSString *balanceAmount;

@end

NS_ASSUME_NONNULL_END
