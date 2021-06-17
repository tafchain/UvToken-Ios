//
//  Wallet+CoreDataProperties.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/18.
//
//

#import "Wallet+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Wallet (CoreDataProperties)

+ (NSFetchRequest<Wallet *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *password;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSString *wallet_id;
@property (nonatomic) BOOL is_backup;
@property (nullable, nonatomic, retain) Coin *coins;

@end

NS_ASSUME_NONNULL_END
