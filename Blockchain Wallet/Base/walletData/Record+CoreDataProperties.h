//
//  Record+CoreDataProperties.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/22.
//
//

#import "Record+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Record (CoreDataProperties)

+ (NSFetchRequest<Record *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSString *address;
@property (nullable, nonatomic, copy) NSString *time;
@property (nullable, nonatomic, copy) NSString *amount;
@property (nullable, nonatomic, copy) NSString *tx_id;
@property (nullable, nonatomic, copy) NSString *result;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *coin_tag;
@property (nullable, nonatomic, copy) NSString *to_address;
@property (nullable, nonatomic, copy) NSString *block_height;
@property (nullable, nonatomic, copy) NSString *miner_fee;
@property (nullable, nonatomic, copy) NSString *memo;
@property (nullable, nonatomic, copy) NSString *start_time;
//20210525
@property (nullable, nonatomic, copy) NSString *gas_price;
@property (nullable, nonatomic, copy) NSString *nonce;

//BTC confirmations小于0并且trusted为false时交易为失败状态
@property (nullable, nonatomic, copy) NSString *trusted;
@property (nullable, nonatomic, copy) NSString *confirmations;

@property (nullable, nonatomic, copy) NSString *valid;//USDT_OMNI false时交易为失败状态

@end

NS_ASSUME_NONNULL_END
