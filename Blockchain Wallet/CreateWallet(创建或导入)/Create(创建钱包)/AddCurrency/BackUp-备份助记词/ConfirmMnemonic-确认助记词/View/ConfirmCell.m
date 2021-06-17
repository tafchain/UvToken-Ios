//
//  ConfirmCell.m
//  Blockchain Wallet
//
//  Created by Panerly on 2020/12/28.
//

#import "ConfirmCell.h"

@implementation ConfirmCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [PTool addBorderWithView:self.bgView Color:baseColor BorderWidth:1 CornerRadius:5];
}

@end
