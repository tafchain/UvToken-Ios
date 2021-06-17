//
//  Coin+CoreDataProperties.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/15.
//
//

#import "Coin+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Coin (CoreDataProperties)

+ (NSFetchRequest<Coin *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *address;
@property (nullable, nonatomic, copy) NSString *wallet_id;
@property (nullable, nonatomic, copy) NSString *key_id;
@property (nullable, nonatomic, copy) NSString *coin_tag;
@property (nullable, nonatomic, copy) NSString *contact_address;
@property (nullable, nonatomic, copy) NSString *image;
@property (nullable, nonatomic, copy) NSString *block_height;
@property (nullable, nonatomic, copy) NSString *balance;

//ERC20代币精度
@property (nullable, nonatomic, copy) NSString *decimals;
//@property (nullable, nonatomic, copy) NSString *coin;
//@property (nullable, nonatomic, copy) NSString *account;
//@property (nullable, nonatomic, copy) NSString *change;
//@property (nullable, nonatomic, copy) NSString *index;
@property (nonatomic) int64_t coin;
@property (nonatomic) int64_t account;
@property (nonatomic) int64_t change;
@property (nonatomic) int64_t index;

@property (nonatomic) BOOL is_backup;
@property (nonatomic) BOOL is_upload;
@property (nullable, nonatomic, retain) Wallet *wallet;

@end

NS_ASSUME_NONNULL_END
