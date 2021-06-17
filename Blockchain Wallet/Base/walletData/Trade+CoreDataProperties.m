//
//  Trade+CoreDataProperties.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/31.
//
//

#import "Trade+CoreDataProperties.h"

@implementation Trade (CoreDataProperties)

+ (NSFetchRequest<Trade *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Trade"];
}

@dynamic address;
@dynamic getShare;
@dynamic firstCoin;
@dynamic lastCoin;
@dynamic status;
@dynamic result;
@dynamic type;
@dynamic des;

@end
