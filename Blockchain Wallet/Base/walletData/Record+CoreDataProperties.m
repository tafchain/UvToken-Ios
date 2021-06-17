//
//  Record+CoreDataProperties.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/22.
//
//

#import "Record+CoreDataProperties.h"

@implementation Record (CoreDataProperties)

+ (NSFetchRequest<Record *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Record"];
}

@dynamic type;
@dynamic address;
@dynamic time;
@dynamic amount;
@dynamic result;
@dynamic tx_id;
@dynamic name;
@dynamic coin_tag;
@dynamic to_address;
@dynamic block_height;
@dynamic miner_fee;
@dynamic memo;
@dynamic start_time;
@dynamic trusted;
@dynamic confirmations;
@dynamic valid;
@dynamic gas_price;
@dynamic nonce;

@end
