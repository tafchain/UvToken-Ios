//
//  CusTextField.m
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/31.
//

#import "CusTextField.h"

@implementation CusTextField

- (void)deleteBackward{
    [super deleteBackward];
    
    if ([self.pjTextFielddelegate respondsToSelector:@selector(pjTextFieldDeleteBackward:)]) {
        [self.pjTextFielddelegate pjTextFieldDeleteBackward:self];
    }
}

@end
