//
//  Wallet+CoreDataProperties.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/18.
//
//

#import "Wallet+CoreDataProperties.h"

@implementation Wallet (CoreDataProperties)

+ (NSFetchRequest<Wallet *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Wallet"];
}

@dynamic name;
@dynamic password;
@dynamic type;
@dynamic wallet_id;
@dynamic is_backup;
@dynamic coins;

@end
