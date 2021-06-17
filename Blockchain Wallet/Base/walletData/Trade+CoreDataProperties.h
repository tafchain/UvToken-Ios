//
//  Trade+CoreDataProperties.h
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/31.
//
//

#import "Trade+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Trade (CoreDataProperties)

+ (NSFetchRequest<Trade *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *address;
@property (nullable, nonatomic, copy) NSString *getShare;
@property (nullable, nonatomic, copy) NSString *firstCoin;
@property (nullable, nonatomic, copy) NSString *lastCoin;
@property (nullable, nonatomic, copy) NSString *status;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSString *des;
@property (nonatomic) BOOL  result;

@end

NS_ASSUME_NONNULL_END
