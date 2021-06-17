//
//  WalletModel.m
//  Blockchain Wallet
//
//  Created by Panerly on 2021/1/13.
//

#import "WalletModel.h"

@implementation WalletModel

- (void)encodeWithCoder:(NSCoder *)coder{
    
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.mnemonics forKey:@"mnemonics"];
    [coder encodeObject:self.password forKey:@"password"];
    [coder encodeObject:self.privateKey forKey:@"privateKey"];
    [coder encodeObject:self.publicKey forKey:@"publicKey"];
}

- (instancetype)initWithCoder:(NSCoder *)coder{
    
    if (self = [super init]) {
        _name = [coder decodeObjectForKey:@"name"];
        _mnemonics = [coder decodeObjectForKey:@"mnemonics"];
        _password = [coder decodeObjectForKey:@"password"];
        _privateKey = [coder decodeObjectForKey:@"privateKey"];
        _publicKey = [coder decodeObjectForKey:@"publicKey"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding{
    return YES;
}
@end
