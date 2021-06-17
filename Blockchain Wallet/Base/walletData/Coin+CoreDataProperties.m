//
//  Coin+CoreDataProperties.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/15.
//
//

#import "Coin+CoreDataProperties.h"

@implementation Coin (CoreDataProperties)

+ (NSFetchRequest<Coin *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Coin"];
}

@dynamic name;
@dynamic address;
@dynamic wallet_id;
@dynamic wallet;
@dynamic key_id;
@dynamic coin_tag;
@dynamic is_backup;
@dynamic is_upload;
@dynamic contact_address;
@dynamic image;
@dynamic block_height;
@dynamic balance;
@dynamic decimals;
@dynamic account;
@dynamic coin;
@dynamic change;
@dynamic index;

@end
