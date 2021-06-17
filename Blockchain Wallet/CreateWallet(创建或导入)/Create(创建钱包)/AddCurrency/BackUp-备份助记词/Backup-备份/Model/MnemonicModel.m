//
//  MnemonicModel.m
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/28.
//

#import "MnemonicModel.h"

@implementation MnemonicModel


- (void)encodeWithCoder:(NSCoder *)coder{
    
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.number forKey:@"number"];
}

- (instancetype)initWithCoder:(NSCoder *)coder{
    
    if (self = [super init]) {
        _name = [coder decodeObjectForKey:@"name"];
        _number = [coder decodeObjectForKey:@"number"];
    }
    return self;
}
+ (BOOL)supportsSecureCoding{
    return YES;
}

@end
